package org.sixstreams.rest.writers;

import java.lang.reflect.Type;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

import org.jobs.model.Applicant;
import org.sixstreams.Constants;
import org.sixstreams.rest.PartialExposeStrategy;
import org.sixstreams.search.AttributeValue;
import org.sixstreams.search.Document;
import org.sixstreams.search.IndexedDocument;
import org.sixstreams.search.SearchHits;
import org.sixstreams.search.data.PersistenceManager;
import org.sixstreams.search.facet.Facet;
import org.sixstreams.search.meta.AttributeDefinition;
import org.sixstreams.search.meta.DocumentDefinition;
import org.sixstreams.search.meta.SearchableGroup;
import org.sixstreams.search.meta.SearchableObject;
import org.sixstreams.search.util.ContextFactory;
import org.sixstreams.social.User;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;

public class JSONWriter extends ResultWriter {

    public String getContentType() {
        return Constants.CONTENT_TYPE_JSON;
    }

    class SearchResult {

        SearchResult(SearchHits hits, List<String> partialRules) {
            PersistenceManager pm = new PersistenceManager();
            items = new ArrayList<Object>();
            // hide secure values from sent out to client
            for (IndexedDocument doc : hits.getIndexedDocuments()) {
                for (AttributeValue av : doc.getAttributeValues()) {
                    if (av.getDefinition().isSecure()) {
                        av.setValue(null);
                    }
                }
            }

            for (IndexedDocument doc : hits.getIndexedDocuments()) {
                objectName = doc.getSearchableObject().getName();
                items.add(pm.toObject(doc, objectName, partialRules));
            }

            offset = hits.getHitsMetaData().getOffset();
            pages = hits.getHitsMetaData().getPages();
            total = hits.getHitsMetaData().getHits();
            facets = hits.getHitsMetaData().getFacets();
            Collection<SearchableGroup> sgs = hits.getHitsMetaData().getSearchableGroups();
            if (sgs != null && sgs.size() > 0) {
                title = sgs.iterator().next().getDisplayName();
            } else {
                title = "Search Results";
            }
        }

        String title;
        List<Object> items;
        long offset;
        long total;
        String objectName;
        long pages;
        String query;
        List<Facet> facets;
    }

    public StringBuffer toString(Object object) {
        return new StringBuffer(toJson(convert(object)));
    }

    public Object convert(Object object) {
        if (object instanceof SearchHits) {
            return new SearchResult((SearchHits) object, excludingAttributes);
        } else if (object instanceof Document) {
            PersistenceManager pm = new PersistenceManager();
            Document doc = (Document) object;
            String objectName = doc.getSearchableObject().getName();
            return pm.toObject(doc, objectName);
        } else if (object instanceof SearchableObject) {
            return new SOWrapper((SearchableObject) object);
        } else if (object instanceof Class) {
            return new ClassWrapper((Class<?>) object);
        } else {
            SearchableObject searchableObject = ContextFactory.getSearchContext().getSearchableObject();
            if (searchableObject != null && searchableObject.getName().equals(object.getClass().getName())) {
                if (excludingAttributes == null) {
                    excludingAttributes = new ArrayList<String>();
                }

                DocumentDefinition df = searchableObject.getDocumentDef();
                for (AttributeDefinition ad : df.getAttrDefs()) {
                    // if an attribute is secure, we will not return that back
                    if (ad.isSecure() || ad.isEncrypted()) {
                        if (!excludingAttributes.contains(ad.getName())) {
                            excludingAttributes.add(ad.getName());
                        }
                    }
                }
            }
            return object;
        }

    }

    private static String DATE_TIME_FORMAT = "yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSS";

    public Object toObject(String string, Class<?> typeOfT) {
        GsonBuilder gsonBuilder = new GsonBuilder();
        Gson gson = gsonBuilder.setDateFormat(DATE_TIME_FORMAT).create();
        return gson.fromJson(string, typeOfT);
    }

    public static void main(String[] args) {
        User anpwang = new User();
        anpwang.setUsername("anpwang");
        anpwang.setPassword("test");
        anpwang.setHintA("question");
        anpwang.setHintQ("annwser");
        Applicant applicant = new Applicant();
        applicant.setIndustry("Test");
        applicant.setFirstName("Anping");
        anpwang.setProfile(applicant);
        JSONWriter writer = new JSONWriter();
        System.err.println(writer.toJson(anpwang));
    }

    public String toJson(Object object) {
        GsonBuilder gsonBuilder = new GsonBuilder();
        if (excludingAttributes != null && excludingAttributes.size() > 0) {
            gsonBuilder.setExclusionStrategies(new PartialExposeStrategy(false, object.getClass().getName(), excludingAttributes));
        }
        if (includingAttributes != null && includingAttributes.size() > 0) {
            gsonBuilder.setExclusionStrategies(new PartialExposeStrategy(true, object.getClass().getName(), includingAttributes));
        }

        Gson gson = gsonBuilder.setDateFormat(DATE_TIME_FORMAT).create();
        return gson.toJson(object);
    }

    public Object toObject(String string, Type type) {
        GsonBuilder gsonBuilder = new GsonBuilder();
        Gson gson = gsonBuilder.setDateFormat(DATE_TIME_FORMAT).create();
        return gson.fromJson(string, type);
    }
}
