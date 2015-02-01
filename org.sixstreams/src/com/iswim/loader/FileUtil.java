package com.iswim.loader;

import java.io.BufferedInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;
import java.io.OutputStream;
import java.lang.reflect.Constructor;
import java.net.URL;

import org.apache.commons.io.IOUtils;

public class FileUtil
{

	public static String stringWithFilePath(final String filePath) throws java.io.IOException
	{
		byte[] buffer = new byte[(int) new File(filePath).length()];
		FileInputStream fis = new FileInputStream(filePath);
		BufferedInputStream f = new BufferedInputStream(new FileInputStream(filePath));
		f.read(buffer);
		fis.close();
		f.close();
		return new String(buffer);
	}

	public static boolean saveFile(URL url, String location, String filename, boolean override)
	{
		File file = null;
		OutputStream fout = null;
		InputStream zin = null;
		// saveFile(url.openStream(), zipname);
		try
		{

			File directory = new File(location);
			if (!directory.exists())
			{
				directory.mkdirs();
			}
			String fileName = location + FileUtil.convertUrl2FileName(filename);
			file = new File(fileName);
			if (!file.exists())
			{
				file.createNewFile();
			}
			else if (!override)
			{
				return false;
			}

			Class<?> theClass = Class.forName("java.io.FileOutputStream");
			Constructor<?> constructor = theClass.getConstructor(java.io.File.class);
			fout = (OutputStream) constructor.newInstance(file);
			zin = url.openStream();
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

	public static void main(String[] args)
	{
		System.err.println(convertUrl2FileName("http://www.yahoo.com/test.zip"));
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