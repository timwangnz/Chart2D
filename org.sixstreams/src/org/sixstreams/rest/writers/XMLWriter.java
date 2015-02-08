package org.sixstreams.rest.writers;

import java.util.Collection;
import java.util.Date;
import java.util.List;

import org.sixstreams.search.AttributeFilter;
import org.sixstreams.search.AttributeValue;
import org.sixstreams.search.HitsMetaData;
import org.sixstreams.search.IndexedDocument;
import org.sixstreams.search.SearchHits;
import org.sixstreams.search.facet.Facet;
import org.sixstreams.search.facet.FacetEntry;
import org.sixstreams.search.meta.SearchableGroup;
import org.sixstreams.search.meta.SearchableObject;
import org.sixstreams.search.query.action.SearchAction;
import org.sixstreams.search.util.EncodeUtil;

public class XMLWriter
        extends ResultWriter {

    public String getContentType() {
        return "text/xml";
    }

    protected StringBuffer toCDATASection(String value) {
        StringBuffer sb = new StringBuffer("<![CDATA[");
        sb.append(value == null ? "" : value);
        sb.append("]]>");
        return sb;
    }

    public StringBuffer toString(Object object) {
        if (object instanceof SearchableGroup[]) {
            return groupsToString((SearchableGroup[]) object);
        } else if (object instanceof SearchHits) {
            return new StringBuffer(searchHits2String((SearchHits) object));
        } else if (object instanceof Throwable) {
            return exceptionToString((Throwable) object);
        }
        return new StringBuffer();
    }

    public String searchHits2String(SearchHits hits) {
        if (hits == null) {
            throw new IllegalArgumentException("Failed to serialize a null SearchHits object!");
        }

        StringBuffer result = new StringBuffer();
        result.append("<?xml version=\"1.0\" encoding=\"UTF-8\"?>");
        result.append("<searchResults>"); //add local
        if (hits.getHitsMetaData() != null) {
            result.append("<hitsMetaData >");
            HitsMetaData hmd = hits.getHitsMetaData();
            //FIXME CDATA
            result.append("<query>").append("<![CDATA[").append(EncodeUtil.cdataEncode(hmd.getQuery())).append("]]>").append("</query>");
            result.append("<offset>").append(hmd.getOffset()).append("</offset>");
            result.append("<pages>").append(hmd.getPages()).append("</pages>");
            result.append("<hits>").append(hmd.getHits()).append("</hits>");

            result.append(toString(hmd.getQueryMetaData()));

            Collection<SearchableGroup> groups = hmd.getSearchableGroups();
            if (groups != null && groups.size() > 0) {
                result.append("<categories >");
                for (SearchableGroup group : groups) {
                    result.append("<category name=\"").append(EncodeUtil.xmlDataEncode(group.getName())).append("\"");
                    result.append(" id=\"").append(group.getId()).append("\" ");
                    result.append(" eid=\"").append(group.getEngineInstanceId()).append("\" ");
                    result.append(" displayName=\"").append(EncodeUtil.xmlDataEncode(group.getDisplayName())).append("\" ");
                    result.append(" scope=\"").append(group.getScope()).append("\" ");
                    result.append("  >");

                    List<SearchableObject> objects = group.getSearchableObjects();
                    if (objects != null && objects.size() > 0) {
                        result.append("<searchableObjects >");
                        for (SearchableObject o : objects) {
                            result.append("<searchableObject name=\"").append(EncodeUtil.xmlDataEncode(o.getName())).append("\"");
                            result.append(" id=\"").append(o.getId()).append("\" ");
                            Date lastCD = o.getLastTimeCrawled();
                            if (lastCD != null) {
                                result.append(" lastTimeCrawled=\"").append(lastCD.getTime()).append("\" ");
                            }
                            result.append(" displayName=\"").append(EncodeUtil.xmlDataEncode(o.getDisplayName())).append("\" />");
                        }
                        result.append("</searchableObjects >");
                    }

                    result.append("</category>");
                }
                result.append("</categories >");
            }

            if (hmd.getAltKeywords() != null) {
                result.append("<altwords>").append("<![CDATA[").append(EncodeUtil.cdataEncode(hmd.getAltKeywords())).append("]]>").append("</altwords>");
            }
            result.append("<timespent >").append(hmd.getTimeSpent()).append("</timespent>");
            if (hmd.isError()) {
                result.append("<error >").append(hmd.getErrorMessage()).append("</error>");
            }
            List<Facet> facets = hmd.getFacets();
            if (facets != null) {
                result.append("<facets >");
                for (Facet facet : facets) {
                    result.append(renderFacet(facet));
                }
                result.append("</facets >");
            }
            List<AttributeFilter> filters = hmd.getFilters();
            if (filters != null && filters.size() > 0) {
                result.append("<filters >");
                for (AttributeFilter filter : filters) {
                    result.append("<filter name=\"").append(EncodeUtil.xmlDataEncode(filter.getAttrName()));
                    result.append("\" operator=\"").append(filter.getOperator());
                    result.append("\" type=\"").append(filter.getAttrbuteType());
                    result.append("\">");
                    result.append(EncodeUtil.xmlDataEncode(filter.getAttrValue()));
                    result.append("</filter >");
                }
                result.append("</filters >");
            }
            result.append("</hitsMetaData >");
        }
        //ActionURLResolver resolver = new ActionURLResolver();
        if (hits.getCount() > 0) {
            result.append("<results >");
            for (int i = 0; i < hits.getCount(); i++) {
                result.append("<result>");
                IndexedDocument doc = hits.getDocument(i);
                result.append("<title><![CDATA[").append(EncodeUtil.cdataEncode(doc.getTitle())).append("]]></title>");
                if (doc.getDefaultAction() != null && doc.getDefaultAction().getTarget() != null) {
                    result.append("<displayUrl><![CDATA[").append(EncodeUtil.cdataEncode(doc.getDefaultAction().getTarget())).append("]]></displayUrl>");
                }
                result.append("<score>").append(doc.getScore()).append("</score>");
                SearchableObject object = doc.getSearchableObject();
                if (object != null) {
                    result.append("<searchableObject name=\"" + object.getName() + "\" eid=\""
                            + object.getSearchEngineInstanceId() + "\" />");
                }
                result.append("<content><![CDATA[").append(EncodeUtil.cdataEncode(doc.getContent())).append("]]></content>");
                String keywords = doc.getKeywords();
                if (keywords != null && keywords.length() != 0) {
                    result.append("<keywords >").append(doc.getKeywords()).append("</keywords>");
                }
                if (doc.getLanguage() != null) {
                    result.append("<lang >").append(doc.getLanguage()).append("</lang>");
                }
                result.append("<attributes>");
                for (AttributeValue attributeValue : doc.getAttributeValues()) {
                    Object value = attributeValue.getValue();
                    if (!isAttributeRendered(attributeValue.getName())) {
                        continue;
                    }
                    result.append("<attribute name=\"").append(EncodeUtil.xmlDataEncode(attributeValue.getName())).append("\" ");
                    result.append(" type=\"").append(attributeValue.getDataType()).append("\" ");
                    result.append(" displayName=\"").append(EncodeUtil.xmlDataEncode(attributeValue.getDisplayName())).append("\" ");
                    result.append(">");
                    if (value != null) {
                        result.append("<![CDATA[");
                        result.append(EncodeUtil.cdataEncode(format(attributeValue.getDataType(), value)));
                        result.append("]]>");
                    }
                    result.append("</attribute>");
                }

                result.append("</attributes>");

                List<SearchAction> actions = doc.getActions();
                if (actions != null && actions.size() > 0) {
                    result.append(toString(actions));
                }
                if (doc.getTags().size() > 0) {
                    result.append("<tags>");
                    for (String tag : doc.getTags()) {
                        result.append(tag).append(" ");
                    }
                    result.append("</tags>");
                }
                result.append("</result>");
            }
            result.append("</results>");
        }
        result.append("</searchResults>");
        return result.toString();
    }

    private String format(String type, Object value) {
        return value == null ? "" : value.toString();
    }

    public StringBuffer exceptionToString(Throwable sgs) {
        StringBuffer result = new StringBuffer();
        result.append("<?xml version=\"1.0\" encoding=\"UTF-8\"?>");
        result.append("<error>").append(sgs.getLocalizedMessage()).append("</error>");
        return result;
    }

    private StringBuffer renderFacet(Facet f) {
        StringBuffer b = new StringBuffer();
        //which facet is self contained
        b.append("<facet");
        b.append(" name=\"").append(EncodeUtil.xmlDataEncode(f.getFacetDef().getName())).append("\"");
        b.append(" attrName=\"").append(EncodeUtil.xmlDataEncode(f.getName())).append("\"");
        b.append(" displayName=\"").append(EncodeUtil.xmlDataEncode(f.getDisplayName())).append("\"");
        b.append(">");

        if (f.getEntries().size() > 0) {
            int i = 0;

            for (FacetEntry entry : f.getEntries()) {
                b.append("<facetEntry");
                b.append(" pname=\"").append(EncodeUtil.xmlDataEncode(entry.getAttrName())).append("\"");

                b.append(" value=\"").append(EncodeUtil.xmlDataEncode(entry.getValue())).append("\"");
                b.append(" count=\"").append(entry.getCount()).append("\"");
                b.append(" displayValue=\"").append(EncodeUtil.xmlDataEncode(entry.getDisplayValue())).append("\"");
                b.append(" />");
                i++;
            }

        }
        b.append("</facet>");
        return b;
    }

    public StringBuffer groupsToString(SearchableGroup[] sgs) {

        StringBuffer result = new StringBuffer();

        result.append("<?xml version=\"1.0\" encoding=\"UTF-8\"?>");
        result.append("<categories>");
        if (sgs != null) {
            for (SearchableGroup sg : sgs) {
                result.append("<category name=\"").append(sg.getName()).append("\"");
                result.append(" eid=\"").append(sg.getEngineInstanceId()).append("\"");
                result.append(" id=\"").append(sg.getId()).append("\"");
                result.append(" displayName=\"").append(sg.getDisplayName()).append("\" ");
                result.append(" scope=\"").append(sg.getScope()).append("\" ");
                result.append(" >");

                if (sg.getSearchableObjects() != null) {
                    result.append("<searchableObjectNames>");
                    for (SearchableObject so : sg.getSearchableObjects()) {
                        result.append("<searchableObjectName name=\"").append(so.getName()).append("\"");
                        result.append("/>");
                    }
                    result.append("</searchableObjectNames>");
                }

                result.append("</category>");
            }
        }
        result.append("</categories>");

        return result;
    }

}
