package org.sixstreams.social;

import java.util.HashMap;
import java.util.Map;

import org.sixstreams.search.data.java.ListOfValues;

public class LocationStateLov extends ListOfValues{
	
	private Map<String, Object> lov = new HashMap<String, Object>();
	
	public Map<String, Object> getLov()
	{
		return lov;
	}
	
	public LocationStateLov()
	{
		lov.put("0","NO PREFERENCE");
		lov.put("AL","Alabama");
		lov.put("AK","Alaska");
		lov.put("AZ","Arizona");
		lov.put("AR","Arkansas");
		lov.put("CA","California");
		lov.put("CO","Colorado");
		lov.put("CT","Connecticut");
		lov.put("DE","Delaware");
		lov.put("DC","District of Columbia");
		lov.put("FL","Florida");
		lov.put("GA","Georgia");
		lov.put("HI","Hawaii");
		lov.put("ID","Idaho");
		lov.put("IL","Illinois");
		lov.put("IN","Indiana");
		lov.put("IA","Iowa");
		lov.put("KS","Kansas");
		lov.put("KY","Kentucky");
		lov.put("LA","Louisiana");
		lov.put("ME","Maine");
		lov.put("MD","Maryland");
		lov.put("MA","Massachusetts");
		lov.put("MI","Michigan");
		lov.put("MN","Minnesota");
		lov.put("MS","Mississippi");
		lov.put("MO","Missouri");
		lov.put("MT","Montana");
		lov.put("NE","Nebraska");
		lov.put("NV","Nevada");
		lov.put("NH","New Hampshire");
		lov.put("NJ","New Jersey");
		lov.put("NM","New Mexico");
		lov.put("NY","New York");
		lov.put("NC","North Carolina");
		lov.put("ND","North Dakota");
		lov.put("OH","Ohio");
		lov.put("OK","Oklahoma");
		lov.put("OR","Oregon");
		lov.put("PA","Pennsylvania");
		lov.put("RI","Rhode Island");
		lov.put("SC","South Carolina");
		lov.put("SD","South Dakota");
		lov.put("TN","Tennessee");
		lov.put("TX","Texas");
		lov.put("UT","Utah");
		lov.put("VT","Vermont");
		lov.put("VA","Virginia");
		lov.put("WA","Washington");
		lov.put("WV","West Virginia");
		lov.put("WI","Wisconsin");
		lov.put("WY","Wyoming");
	}
}
