package com.iswim.model;

import org.sixstreams.search.data.java.annotations.Searchable;
import org.sixstreams.search.data.java.annotations.SearchableAttribute;
import org.sixstreams.social.Person;

@Searchable(title = "firstName")
public class Swimmer extends Person {

    @SearchableAttribute(facetName = "club", facetPath = "club")
    private String club;

    @SearchableAttribute
    private String LSC;

    @SearchableAttribute
    private String swimmerUSSNo;

    @SearchableAttribute
    private String group;

    public Swimmer() {

    }

    public Swimmer(String name) {
        super(name);
    }

    public String getLSC() {
        return LSC;
    }

    public void setLSC(String lSC) {
        LSC = lSC;
    }

    public String getSwimmerUSSNo() {
        return swimmerUSSNo;
    }

    public void setSwimmerUSSNo(String swimmerUSSNo) {
        this.swimmerUSSNo = swimmerUSSNo;
    }

    public void setClub(String club) {
        this.club = club;
    }

    public String getClub() {
        return club;
    }

    public void setGroup(String group) {
        this.group = group;
    }

    public String getGroup() {
        return group;
    }
}
