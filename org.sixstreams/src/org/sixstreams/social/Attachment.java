package org.sixstreams.social;

public class Attachment extends SocialAction
{

	@Override
	public String getVerb()
	{
		return "upload";
	}

	public void onDelete()
	{
		//does nothting
	}
	public void onCreate()
	{
		//does nothting
	}
	public void preCreate()
	{
		
	}
}
