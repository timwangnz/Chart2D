package com.iswim.model;

import java.util.Date;

import org.sixstreams.search.data.java.annotations.Searchable;
import org.sixstreams.search.data.java.annotations.SearchableAttribute;

 
@Searchable(title="name")
public class Meet { 
	@SearchableAttribute(isKey=true)
	private String uniqueName;

	private String fileName;
	
	@SearchableAttribute
	private String course;


	@SearchableAttribute
	private String url;

	@SearchableAttribute
	private String orgId;

	@SearchableAttribute
	private String hostName;

	@SearchableAttribute
	private String phone;

	private String[] hostTeams;


	@SearchableAttribute
	private Date startDate;

	@SearchableAttribute
	private Date endDate;


	@SearchableAttribute
	private int altitude; // pool

	@SearchableAttribute
	private char meetCode;


	@SearchableAttribute
	private String city;

	@SearchableAttribute
	private String streetLine1;

	@SearchableAttribute
	private String streetLine2;

	@SearchableAttribute
	private String region;

	@SearchableAttribute
	private String postalCode;

	@SearchableAttribute
	private String state;

	@SearchableAttribute
	private String country;


	@SearchableAttribute
	private String comment;

	@SearchableAttribute
	private String name;

	public void _setAddress(Address address) {
		if (address == null)
		{
			return;
		}
		this.city = address.getCity();
		this.streetLine1 = address.getStreetLine1();
		this.streetLine2 = address.getStreetLine2();
		this.postalCode = address.getPostalCode();
		this.state = address.getState();
		this.country = address.getCountry();
		this.region = address.getRegion();
	}
	
	public String getRegion() {
		return region;
	}

	public void setRegion(String region) {
		this.region = region;
	}

	public String getCity() {
		return city;
	}

	public void setCity(String city) {
		this.city = city;
	}

	public String getStreetLine1() {
		return streetLine1;
	}

	public void setStreetLine1(String streetLine1) {
		this.streetLine1 = streetLine1;
	}

	public String getStreetLine2() {
		return streetLine2;
	}

	public void setStreetLine2(String streetLine2) {
		this.streetLine2 = streetLine2;
	}

	public String getPostalCode() {
		return postalCode;
	}

	public void setPostalCode(String postalCode) {
		this.postalCode = postalCode;
	}

	public String getState() {
		return state;
	}

	public void setState(String state) {
		this.state = state;
	}

	public String getCountry() {
		return country;
	}

	public void setCountry(String country) {
		this.country = country;
	}

	public char getMeetCode() {
		return meetCode;
	}

	public void setMeetCode(char meetCode) {
		this.meetCode = meetCode;
	}

	public Meet(String meet) {
		uniqueName = meet;
	}

	public void setAltitude(int altitude) {
		this.altitude = altitude;
	}

	public int getAltitude() {
		return altitude;
	}

	public void setCourse(String course) {
		this.course = course;
	}

	public String getCourse() {
		return course;
	}

	public void setHostTeams(String[] teams) {
		this.hostTeams = teams;
	}

	public String[] getHostTeams() {
		return hostTeams;
	}

	public void setUrl(String url) {
		this.url = url;
	}

	public String getUrl() {
		return url;
	}

	public String getOrgId() {
		return orgId;
	}

	public void setOrgId(String orgId) {
		this.orgId = orgId;
	}

	public String getHostName() {
		return hostName;
	}

	public void setHostName(String hostName) {
		this.hostName = hostName;
	}

	public String getPhone() {
		return phone;
	}

	public void setPhone(String phone) {
		this.phone = phone;
	}

	public void setStartDate(Date startDate) {
		this.startDate = startDate;
	}

	public Date getStartDate() {
		return startDate;
	}

	public void setEndDate(Date endDate) {
		this.endDate = endDate;
	}

	public Date getEndDate() {
		return endDate;
	}

	public String getUniqueName() {
		// TODO Auto-generated method stub
		return uniqueName;
	}

	public void setUniqueName(String name) {
		this.uniqueName = name;
	}

	public String toString() {
		return this.hostName + " \n" + this.city + " \n" + this.postalCode
				+ " \n" + this.meetCode + " \n" + this.startDate + "\n"
				+ this.endDate + "\n" + this.url;
	}

	public String _getAddress() {
		return this.city + ", " + this.postalCode;
	}

	public void setComment(String comment) {
		this.comment = comment;
	}

	public String getComment() {
		return comment;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getName() {
		return name == null ? uniqueName : name;
	}

	public void setFileName(String fileName)
	{
		this.fileName = fileName;
	}

	public String getFileName()
	{
		return fileName;
	}

}
