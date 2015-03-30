package org.sixstreams.app.data;

import org.sixstreams.search.data.java.annotations.Searchable;

import org.sixstreams.social.Person;

@Searchable(title = "firstName + ' ' + lastName + ' - ' + jobTitle")
public class Contact extends Person {

    private String companyName;
    private String industry;
    private String subIndustry;

    private String accountId;

    private String dunsNumber;

    private String roleId;

    private String mrcCode;

    private long employees;

    private long revenue;

    private String ownership;

    private String domainType;

    private String fortuneRank;

    private String sizeInRevenue;
    private String sizeInEmployees;

    public void setAccountId(String accountId) {
        this.accountId = accountId;
    }

    public String getAccountId() {
        return accountId;
    }

    public String getDunsNumber() {
        return dunsNumber;
    }

    public void setDunsNumber(String dunsNumber) {
        this.dunsNumber = dunsNumber;
    }

    public String getRoleId() {
        return roleId;
    }

    public void setRoleId(String roleId) {
        this.roleId = roleId;
    }

    public String getMrcCode() {
        return mrcCode;
    }

    public void setMrcCode(String mrcCode) {
        this.mrcCode = mrcCode;
    }

    public void setEmployees(long employees) {
        this.employees = employees;
    }

    public long getEmployees() {
        return employees;
    }

    public void setRevenue(long revenue) {
        this.revenue = revenue;
    }

    public long getRevenue() {
        return revenue;
    }

    public void setOwnership(String ownership) {
        this.ownership = ownership;
    }

    public String getOwnership() {
        return ownership;
    }

    public void setDomainType(String domainType) {
        this.domainType = domainType;
    }

    public String getDomainType() {
        return domainType;
    }

    public void setFortuneRank(String fortuneRank) {
        this.fortuneRank = fortuneRank;
    }

    public String getFortuneRank() {
        return fortuneRank;
    }

    public void setSizeInRevenue(String sizeInRevenue) {
        this.sizeInRevenue = sizeInRevenue;
    }

    public String getSizeInRevenue() {
        return sizeInRevenue;
    }

    public void setSizeInEmployees(String sizeInEmployees) {
        this.sizeInEmployees = sizeInEmployees;
    }

    public String getSizeInEmployees() {
        return sizeInEmployees;
    }

    public String getCompanyName() {
        return companyName;
    }

    public void setCompanyName(String companyName) {
        this.companyName = companyName;
    }

    public String getIndustry() {
        return industry;
    }

    public void setIndustry(String industry) {
        this.industry = industry;
    }

    public String getSubIndustry() {
        return subIndustry;
    }

    public void setSubIndustry(String subIndustry) {
        this.subIndustry = subIndustry;
    }
}
