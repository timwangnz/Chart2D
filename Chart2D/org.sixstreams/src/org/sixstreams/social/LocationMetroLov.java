package org.sixstreams.social;

import java.util.HashMap;
import java.util.Map;

import org.sixstreams.search.data.java.ListOfValues;

public class LocationMetroLov extends ListOfValues{
	
	private Map<String, Object> lov = new HashMap<String, Object>();
	
	public Map<String, Object> getLov()
	{
		return lov;
	}
	
	public LocationMetroLov()
	{
		lov.put("atlanta-ga", "Atlanta, GA");
		lov.put("austin-tx", "Austin, TX");
		lov.put("baltimore-md", "Baltimore, MD");
		lov.put("birmingham-al", "Birmingham, AL");
		lov.put("boston-ma", "Boston, MA");
		lov.put("buffalo-ny", "Buffalo, NY");
		lov.put("calgary-ab", "Calgary, AB");
		lov.put("charlotte-nc", "Charlotte, NC");
		lov.put("chicago-il", "Chicago, IL");
		lov.put("cincinnati-oh", "Cincinnati, OH");
		lov.put("cleveland-oh", "Cleveland, OH");
		lov.put("columbus-oh", "Columbus, OH");
		lov.put("dallas-tx", "Dallas, TX");
		lov.put("denver-co", "Denver, CO");
		lov.put("des-moines-ia", "Des Moines, IA");
		lov.put("detroit-mi", "Detroit, MI");
		lov.put("hartford-ct", "Hartford, CT");
		lov.put("houston-tx", "Houston, TX");
		lov.put("indianapolis-in", "Indianapolis, IN");
		lov.put("jacksonville-fl", "Jacksonville, FL");
		lov.put("kansas-city-mo", "Kansas City, MO");
		lov.put("las-vegas-nv", "Las Vegas, NV");
		lov.put("los-angeles-ca", "Los Angeles, CA");
		lov.put("louisville-ky", "Louisville, KY");
		lov.put("memphis-tn", "Memphis, TN");
		lov.put("miami-fl", "Miami, FL");
		lov.put("milwaukee-wi", "Milwaukee, WI");
		lov.put("minneapolis-mn", "Minneapolis, MN");
		lov.put("montreal-qc", "Montreal, QC");
		lov.put("nashville-tn", "Nashville, TN");
		lov.put("new-orleans-la", "New Orleans, LA");
		lov.put("new-york-ny", "New York, NY");
		lov.put("oklahoma-city-ok", "Oklahoma City, OK");
		lov.put("orlando-fl", "Orlando, FL");
		lov.put("philadelphia-pa", "Philadelphia, PA");
		lov.put("phoenix-az", "Phoenix, AZ");
		lov.put("pittsburgh-pa", "Pittsburgh, PA");
		lov.put("portland-me", "Portland, ME");
		lov.put("portland-or", "Portland, OR");
		lov.put("providence-ri", "Providence, RI");
		lov.put("raleigh-nc", "Raleigh, NC");
		lov.put("richmond-va", "Richmond, VA");
		lov.put("rochester-ny", "Rochester, NY");
		lov.put("sacramento-ca", "Sacramento, CA");
		lov.put("salt-lake-city-ut", "Salt Lake City, UT");
		lov.put("san-antonio-tx", "San Antonio, TX");
		lov.put("san-bernardino-ca", "San Bernardino, CA");
		lov.put("san-diego-ca", "San Diego, CA");
		lov.put("san-francisco-ca", "San Francisco, CA");
		lov.put("seattle-wa", "Seattle, WA");
		lov.put("silicon-valley", "Silicon Valley");
		lov.put("st-louis-mo", "St Louis, MO");
		lov.put("tampa-fl", "Tampa, FL");
		lov.put("toronto-on", "Toronto, ON");
		lov.put("vancouver-bc", "Vancouver, BC");
		lov.put("virginia-beach-va", "Virginia Beach, VA");
		lov.put("washington-dc", "Washington, DC");
	}
}
