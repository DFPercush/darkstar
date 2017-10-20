function serialize(x)
	local ty = type(x);
	if (ty == "string") then
		return "\"" .. x .. "\"";
	elseif (ty == "nil") then
		return "nil";
	elseif (ty == "boolean") then
		if (x == true) then
			return "true";
		else
			return "false";
		end
	elseif (ty == "number") then
		return tostring(x);
	elseif (ty == "userdata") then
		return "(userdata)";
	elseif (ty == "function") then
		return "(function)";
	elseif (ty == "thread") then
		return "(thread)";
	elseif (ty == "table") then
		local k, v;
		local ret = "{";
		for k, v in pairs(x) do
			if (string.len(ret) > 1) then
				ret = ret .. ",";
			end
			ret = ret .. "[" .. DumpToString(k) .. "]=" .. DumpToString(v);
		end
		ret = ret .. "}"
		return ret;
	else
		return "(unknown)";
	end
	return "(ControlFlowError)";
end

