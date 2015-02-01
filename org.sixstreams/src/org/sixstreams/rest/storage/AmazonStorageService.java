package org.sixstreams.rest.storage;

import java.io.InputStream;
import java.io.OutputStream;
import org.apache.commons.io.IOUtils;
import org.sixstreams.rest.RestBaseResource;
import org.sixstreams.rest.RestfulException;
import org.sixstreams.rest.StorageService;

import com.amazonaws.auth.AWSCredentials;
import com.amazonaws.auth.PropertiesCredentials;
import com.amazonaws.services.s3.AmazonS3Client;
import com.amazonaws.services.s3.model.ObjectMetadata;
import com.amazonaws.services.s3.model.S3Object;
import com.amazonaws.services.s3.model.S3ObjectInputStream;

public class AmazonStorageService implements StorageService
{
	static private String BUCKET_NAME = "amazon.sixstreams.com";
	static AWSCredentials credentials;
	static
	{
		try
		{
			credentials = new PropertiesCredentials(Thread.currentThread().getContextClassLoader().getResourceAsStream("AwsCredentials.properties"));
			AmazonS3Client s3 = new AmazonS3Client(credentials);
			s3.createBucket(BUCKET_NAME);
		}
		catch (Exception e)
		{
			e.printStackTrace();
		}
	}

	@Override
	public int read(OutputStream outputStream, String resourceId, RestBaseResource owner)
	{
		try
		{
			AmazonS3Client s3 = new AmazonS3Client(credentials);
			S3Object s3Obj = s3.getObject(BUCKET_NAME, resourceId);
			S3ObjectInputStream inputStream = s3Obj.getObjectContent();
			int bytesCopied = IOUtils.copy(s3Obj.getObjectContent(), outputStream);
			inputStream.close();
			return bytesCopied;
		}
		catch (Exception e)
		{
			throw new RestfulException(500, "Failed to read from storage service", "Amazon");
		}

	}

	@Override
	public boolean delete(RestBaseResource owner)
	{
		try
		{
			AmazonS3Client s3 = new AmazonS3Client(credentials);
			s3.deleteObject(BUCKET_NAME, owner.getId());
			return true;
		}
		catch (Exception e)
		{
			throw new RestfulException(500, "Failed to delete from storage service", "Amazon");
		}
	}

	@Override
	public void save(InputStream inputStream, String fileName, String contentType, RestBaseResource owner)
	{
		try
		{
			AmazonS3Client s3 = new AmazonS3Client(credentials);
			ObjectMetadata omd = new ObjectMetadata();
			omd.setContentType(owner.getContentType());
			omd.setHeader("owner", owner.getName());
			s3.putObject(BUCKET_NAME, fileName, inputStream, omd);
		}
		catch (Exception e)
		{
			throw new RestfulException(500, "Failed to save to storage service", "Amazon");
		}
	}

}
