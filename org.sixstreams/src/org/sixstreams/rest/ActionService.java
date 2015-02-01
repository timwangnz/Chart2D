package org.sixstreams.rest;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public interface ActionService
{
	public boolean performService(HttpServletRequest request, HttpServletResponse response) throws RestfulException;
}
