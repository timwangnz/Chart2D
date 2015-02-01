package org.sixstreams.rest;

import java.io.InputStream;
import java.io.OutputStream;
public interface StorageService
{
	public int read(OutputStream outputStream, String resourceId, RestBaseResource owner);
	public boolean delete(RestBaseResource owner);
	public void save(InputStream inputStream, String resourceId, String contentType, RestBaseResource owner);
}
