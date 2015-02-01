package org.sixstreams.rest;


public interface RestBaseResource
{
	/**
	 * Length of the file
	 * @return
	 */
	int getContentLength();
	/**
	 * Type of the file
	 * @return
	 */
	String getContentType();
	/**
	 * Returns application Id
	 * @return applicaiton id
	 */
	String getAppId();
	/**
	 * Id of owning object. In some cases, a person, or a car, or a restaurant
	 * @return
	 */
	String getParentId();
	/**
	 * Type of owning object. The class name of the owning object
	 * @return
	 */
	String getParentType();
	/**
	 * Name for the resource, human readable, such as test.png
	 * @return
	 */
	String getName();
	
	/**
	 * Guid
	 * @return
	 */
	String getId();
	String getIconId();
	
	void setContentUrl(String contentUrl);
	void setIconUrl(String iconUrl);
}
