package com.iswim.model;
 

import java.util.Date;
import java.util.List;

public class Practice {
	
	private String uniqueName;

	private String owner; //team

	private Date date;

	private boolean required;

	private float duration;

	private String summary;
	

	private Address address;
	

	private List<Swimmer> attendance;
	
	public String getOwner() {
		return owner;
	}
	public void setOwner(String owner) {
		this.owner = owner;
	}
	public Date getDate() {
		return date;
	}
	public void setDate(Date date) {
		this.date = date;
	}
	public boolean isRequired() {
		return required;
	}
	public void setRequired(boolean required) {
		this.required = required;
	}
	public float getDuration() {
		return duration;
	}
	public void setDuration(float duration) {
		this.duration = duration;
	}
	public void setUniqueName(String uniqueName) {
		this.uniqueName = uniqueName;
	}
	public String getUniqueName() {
		return uniqueName;
	}
	
	public void setSummary(String summary) {
		this.summary = summary;
	}
	
	public String getSummary() {
		return summary;
	}
	
	public void setAddress(Address address) {
		this.address = address;
	}
	
	public Address getAddress() {
		return address;
	}
	
	public void addAttendance(Swimmer attendance)
	{
		if (!this.attendance.contains(attendance))
		{
			this.attendance.add(attendance);
		}
	}
	public void setAttendance(List<Swimmer> attendance) {
		this.attendance = attendance;
	}
	public List<Swimmer> getAttendance() {
		return attendance;
	}
}
