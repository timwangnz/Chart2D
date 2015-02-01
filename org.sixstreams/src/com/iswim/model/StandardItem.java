package com.iswim.model;

import java.util.Map;

 
public class StandardItem extends Event {

	private String name;

	private String standardName;

	private String standardBody;

	private long time;

	public StandardItem(Map<String, String> map) {
		name = map.get("name");
		standardName = map.get("standardName");
		time = Long.valueOf(map.get("time") == null ? "60000":map.get("time"));
		setCourse(map.get("course"));
		setDistance(Integer.valueOf(map.get("distance")));
		setGender(map.get("gender"));
		setStroke(map.get("stroke"));
		setAge(map.get("age"));
	}

	public boolean isEqualTo(Map<String, String> map) {		
		return name.equals(map.get("name"))
				&& standardName.equals(map.get("standardName"))
				&& getStroke().equals(map.get("stroke"))
				&& getGender().equals(map.get("gender"))
				&& getCourse().equals(map.get("course"))
				&& getAge().equals(map.get("age"))
				&& getDistance() == Integer.valueOf(map.get("distance"));
	}

	public String toString() {
		return getStroke() + "," + getGender() + ","
				+ getAge() + "," + getDistance() + "," + getCourse() + ","
				+ getName() + "," + getTime();
	}

	public String toPlistKey() {
		return "<key>c</key><string>" + getCourse() + "</string><key>g</key><string>" + getGender() + "</string><key>age</key><string>" 
				+ getAge() + "</string><key>d</key><string>" + getDistance() +"</string>";
	}
	
	public String toPListItem() {
		return "<dict><key>name</key><string>"+ getName() + "</string><key>time</key><string>" + getTime() + "</string></dict>";
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getName() {
		return name;
	}

	public void setStandardBody(String standardBody) {
		this.standardBody = standardBody;
	}

	public String getStandardBody() {
		return standardBody;
	}

	public void setTime(long time) {
		this.time = time;
	}

	public long getTime() {
		return time;
	}

	public void setStandardName(String standardName) {
		this.standardName = standardName;
	}

	public String getStandardName() {
		return standardName;
	}
}
