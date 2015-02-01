package com.iswim.model;

import java.util.Date;


public class BigData extends Inheritable
{
	private String owner;
	private String dataType;
	private Date saved;
	private String context;
	private String bigData;
	
	public String getOwner() {
		return owner;
	}
	public void setOwner(String owner) {
		this.owner = owner;
	}
	public String getDataType() {
		return dataType;
	}
	public void setDataType(String dataType) {
		this.dataType = dataType;
	}
	public Date getSaved() {
		return saved;
	}
	public void setSaved(Date saved) {
		this.saved = saved;
	}
	public String getContext() {
		return context;
	}
	public void setContext(String context) {
		this.context = context;
	}
	
	public String getBigData() {
		return bigData;
	}
	public void setBigData(String bigData) {
		this.bigData = bigData;
	}
	
	public String toString()
	{
		return owner + "\n" + dataType + "\n" + bigData + "\n" + saved;
	}
	
}
