package org.sixstreams.rest;

import org.sixstreams.search.meta.MetaDataManager;
import org.sixstreams.search.util.ClassUtil;
 
public class StorageServiceFactory
{
	private static String storageClass = MetaDataManager.getProperty("org.sixstreams.search.content.storageservice.class");
	public static synchronized StorageService getService()
	{
		if (storageClass == null)
		{
			storageClass = "org.sixstreams.rest.storage.AmazonStorageService";
		}
		return (StorageService) ClassUtil.create(storageClass);
	}
}
