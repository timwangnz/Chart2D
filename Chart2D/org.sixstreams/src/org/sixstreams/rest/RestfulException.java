package org.sixstreams.rest;

import java.io.Serializable;

import org.sixstreams.rest.writers.ResultWriterProxy;

public class RestfulException extends RuntimeException
{
	static class JsonMsg implements Serializable
	{
		int code;
		String message;
		String status;
		String source;		
	}
	private int code;
	private JsonMsg jsonMessage = new JsonMsg();
	
	public RestfulException(int code, String message, String source)
	{
		super(message);
		jsonMessage.message = message;
		jsonMessage.source = source;
		jsonMessage.status = "Severe";
		jsonMessage.code = code;
		this.code = code;
	}
	
	public String toString()
	{
		ResultWriterProxy writer = new ResultWriterProxy("application/json");
		return writer.toString(this.jsonMessage).toString();
	}

	public int getCode()
	{
		return code;
	}

	public void setCode(int code)
	{
		this.code = code;
	}
}
