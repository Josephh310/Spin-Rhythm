local Loader = {}

type Callable = (...any) -> ...any

local function TryRequire(Module: ModuleScript): any?
	print(`[Loader] Requiring {Module:GetFullName()}`)
	local Success, Result = pcall(require, Module)
	if not Success then
		warn(`[Loader] Failed to require {Module:GetFullName()}: {Result}`)
		return nil
	end
	print(`[Loader] Required {Module:GetFullName()}`)
	return Result
end

local function ProtectedCall(Module: ModuleScript, Method: string, Function: Callable, ...)
	-- Called without the module table: handlers are `function M.Method(...)`.
	print(`[Loader] Calling {Module:GetFullName()}.{Method}`)
	local Success = xpcall(Function, function(Err)
		warn(`[Loader] {Module:GetFullName()}.{Method} errored: {Err}\n{debug.traceback()}`)
	end, ...)
	if Success then
		print(`[Loader] Finished {Module:GetFullName()}.{Method}`)
	end
end

local function ResolveFunction(Module: ModuleScript, Method: string): Callable?
	-- nil if the require failed or the method is missing.
	local Required = TryRequire(Module)
	if Required == nil then
		return nil
	end
	local Function = Required[Method]
	if type(Function) ~= "function" then
		warn(`[Loader] {Module:GetFullName()} has no method '{Method}', skipping`)
		return nil
	end
	return Function
end

function Loader.CallMethod(Module: ModuleScript, Method: string, ...)
	-- Deferred so the caller returns before the method runs.
	local Function = ResolveFunction(Module, Method)
	if Function then
		task.defer(ProtectedCall, Module, Method, Function, ...)
	end
end

function Loader.CallMethodAsync(Module: ModuleScript, Method: string, ...)
	-- Runs inline and yields until the method completes.
	local Function = ResolveFunction(Module, Method)
	if Function then
	    ProtectedCall(Module, Method, Function, ...)
	end
end

return Loader
