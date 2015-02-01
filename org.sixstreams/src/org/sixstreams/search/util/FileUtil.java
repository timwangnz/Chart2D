package org.sixstreams.search.util;

import java.io.BufferedReader;
import java.io.ByteArrayInputStream;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.BufferedInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.UnsupportedEncodingException;
import java.lang.reflect.Constructor;
import java.net.URL;

import org.apache.commons.io.IOUtils;

public class FileUtil
{

	public static String read(String filePath) throws java.io.IOException
	{
		StringBuffer fileData = new StringBuffer(1000);
		BufferedReader reader = new BufferedReader(new FileReader(filePath));
		char[] buf = new char[1024];
		int numRead = 0;
		while ((numRead = reader.read(buf)) != -1)
		{
			String readData = String.valueOf(buf, 0, numRead);
			fileData.append(readData);
			buf = new char[1024];
		}
		reader.close();
		return fileData.toString();
	}

	public static String stringWithFilePath(final String filePath) throws java.io.IOException
	{
		byte[] buffer = new byte[(int) new File(filePath).length()];
		FileInputStream fis = new FileInputStream(filePath);
		BufferedInputStream f = new BufferedInputStream(new FileInputStream(filePath));
		f.read(buffer);
		fis.close();
		return new String(buffer);
	}

	public static boolean saveFile(URL url, String location, String filename, boolean override) throws IOException
	{
		return saveFile(url.openStream(), location, filename, override);
	}
	
	public static boolean saveFile(InputStream zin, String location, String filename, boolean override)
	{
		File file = null;
		OutputStream fout = null;
		try
		{
			File directory = new File(location);
			if (!directory.exists())
			{
				directory.mkdirs();
			}
			String fileName = location + File.separator+ FileUtil.convertUrl2FileName(filename);
			file = new File(fileName);
			if (!file.exists())
			{
				file.createNewFile();
			}

			if (!override)
			{
				return false;
			}

			Class<?> theClass = Class.forName("java.io.FileOutputStream");
			Constructor<?> constructor = theClass.getConstructor(java.io.File.class);
			fout = (OutputStream) constructor.newInstance(file);
			IOUtils.copy(zin, fout);
		}
		catch (Exception e)
		{
			if (file != null && file.exists())
			{
				file.delete();
			}
		}
		finally
		{
			IOUtils.closeQuietly(zin);
			IOUtils.closeQuietly(fout);
		}
		return true;
	}

	public static boolean saveFile(String json, String location, String filename, boolean override) throws UnsupportedEncodingException
	{
		return saveFile(new ByteArrayInputStream(json.getBytes("UTF8")), location, filename, override);	
	}
	
	public static boolean saveFile(File file, String location, String filename, boolean override) throws FileNotFoundException
	{
		return saveFile(new FileInputStream(file), location, filename, override);
	}
	
	public static String convertUrl2FileName(String url)
	{
		String fileExt = "";
		if (url.lastIndexOf(".") != -1)
		{
			fileExt = url.substring(url.lastIndexOf("."));
			url = url.substring(0, url.lastIndexOf("."));
		}
		url = url.replace("//", "_");
		url = url.replace("/", "_");
		url = url.replace(".", "_");
		url = url.replace(":", "");
		return url + fileExt;
	}

	public static void copy(InputStream in, OutputStream out)
	{
		try
		{
			byte[] buf = new byte[1024];
			long bytes = 0;
			int len;
			while ((len = in.read(buf)) > 0)
			{
				out.write(buf, 0, len);
				bytes += len;
			}
			System.out.println("File copied, total " + bytes + " bytes.");
		}
		catch (Exception e)
		{
			System.out.println(e.getMessage());
		}
	}
}
