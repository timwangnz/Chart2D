package org.sixstreams.search.data.java;

import java.util.HashMap;
import java.util.Map;

public class ListOfValues implements java.io.Serializable 
{
	protected Map<String, Object> lov = new HashMap<String, Object>();

	public Map<String, Object> getLov()
	{
		return lov;
	}
}
