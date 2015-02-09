package org.sixstreams.search.data;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

import org.sixstreams.Constants;
import org.sixstreams.rest.GoodCache;
import org.sixstreams.search.AttributeFilter;
import org.sixstreams.search.Document;
import org.sixstreams.search.IndexableDocument;
import org.sixstreams.search.Indexer;
import org.sixstreams.search.IndexingException;
import org.sixstreams.search.QueryMetaData;
import org.sixstreams.search.SearchContext;
import org.sixstreams.search.SearchEngine;
import org.sixstreams.search.SearchException;
import org.sixstreams.search.SearchHits;
import org.sixstreams.search.crawl.crawler.IndexableDocumentImpl;
import org.sixstreams.search.data.java.DocumentDefinitionImpl;
import org.sixstreams.search.data.java.DocumentService;
import org.sixstreams.search.data.java.SearchableDataObject;
import org.sixstreams.search.data.java.XMLReader;
import org.sixstreams.search.data.java.XMLWriter;
import org.sixstreams.search.meta.AttributeDefinition;
import org.sixstreams.search.meta.Configurable;
import org.sixstreams.search.meta.DocumentDefinition;
import org.sixstreams.search.meta.MetaDataManager;
import org.sixstreams.search.meta.SearchableObject;
import org.sixstreams.search.query.QueryMetaDataImpl;
import org.sixstreams.search.query.SearchGroup;
import org.sixstreams.search.util.ClassUtil;
import org.sixstreams.search.util.ContextFactory;

public class PersistenceManager {

    protected static final Logger sLogger = Logger.getLogger(PersistenceManager.class.getName());
    private int offset = Constants.DEFAULT_OFFSET;
    private int pageSize = Constants.DEFAULT_PAGE_SIZE;
    private boolean enableFacet = false;

    public void close() {
        SearchEngine engine = MetaDataManager.getSearchEngine(-1L);
        engine.cleanup();
    }

    public static IndexableDocument createDocument(long engineId, Object object) {
        SearchableDataObject searchableObject = (SearchableDataObject) getSearchableObject(engineId, object.getClass());
        IndexableDocument doc = new IndexableDocumentImpl(searchableObject);
        searchableObject.assign(doc, object);
        DocumentService.evaluateExpression(doc);
        return doc;
    }

    public static IndexableDocument createDocument(Object object) {
        return createDocument(Constants.INVALID_ENGINE_INST_ID, object);
    }

    public void delete(Document doc) throws IndexingException {
        DocumentService ds = new DocumentService(doc.getSearchableObject());
        ds.deleteDocument(doc);
    }

    public void delete(Object object) throws IndexingException {
        SearchableObject so = getSearchableObject(Constants.INVALID_ENGINE_INST_ID, object.getClass());
        DocumentService ds = new DocumentService(so);
        ds.deleteDataObject(object);
    }

    public <T> Object getObjectById(String objectId, Class<T> clazz) throws SearchException {
        SearchableObject so = getSearchableObject(Constants.INVALID_ENGINE_INST_ID, clazz);
        Map<String, Object> filter = new HashMap<>();
        so.getDocumentDef().getKeyAttrDefs().stream().forEach((af) -> {
            filter.put(af.getName(), objectId);
        });
        List<T> objects = query(filter, clazz);
        if (objects == null || objects.size() != 1) {
            return null;
        }
        return objects.get(0);
    }

    public void delete(long engineId, Object object) throws IndexingException {
        SearchableObject so = getSearchableObject(engineId, object.getClass());
        DocumentService ds = new DocumentService(so);
        ds.deleteDataObject(object);
        GoodCache.getCache(object.getClass().getName()).delete(object);
    }

    public void deleteByQuery(long engineId, Class<?> clazz, String query) throws IndexingException {
        sLogger.log(Level.INFO, "Delete objects by query {0}", query);
        SearchableObject so = getSearchableObject(engineId, clazz);
        DocumentService ds = new DocumentService(so);
        ds.deleteDataObject(query);
    }

    public void insert(Object object) throws IndexingException {
        if (object != null) {
            insert(Constants.INVALID_ENGINE_INST_ID, object);
        }
    }

    public void insert(long engineId, Object obj) throws IndexingException {
        SearchableObject so = getSearchableObject(engineId, obj.getClass());
        DocumentService ds = new DocumentService(so);
        ds.postDataObject(obj);
    }

    public void update(Document doc) throws IndexingException {
        SearchableObject so = doc.getSearchableObject();
        if (so == null) {
            sLogger.severe("Can not update a document with searchable object");
            return;
        }
        Object object = toObject(doc, so.getName());
        if (object != null) {
            updateObject(so.getSearchEngineInstanceId(), object);
        }
    }

    private void updateObject(long eid, Object object) throws IndexingException {
        if (object != null) {
			//
            // update cache for all the objects
            // this assume the cache is distributed
            //
            GoodCache.getCache(object.getClass().getName()).update(object);
            insert(eid, object);
        }
    }

    public void update(Object object) throws IndexingException {
        updateObject(Constants.INVALID_ENGINE_INST_ID, object);
    }

    public void update(SearchableObject so, Object object) throws IndexingException {
        if (so == null) {
            sLogger.severe("Can not update a document with searchable object");
            return;
        }
        updateObject(so.getSearchEngineInstanceId(), object);
    }

    public void insert(List<?> objects) throws IndexingException {
        if (objects != null && objects.size() > 0) {
            insert(Constants.INVALID_ENGINE_INST_ID, objects);
        }
    }

    public void insert(long engineId, List<?> objects) throws IndexingException {
        if (objects == null || objects.isEmpty()) {
            throw new IllegalArgumentException("Expect the list of objects not null nor empty");
        }
        SearchableObject so = getSearchableObject(engineId, objects.get(0).getClass());
        DocumentService ds = new DocumentService(so);
        ds.postDataObjects(objects);
    }

    // query to get list of object
    public <T> List<T> query(String query, Map<String, Object> filters, Class<T> clazz, int start, int limit) throws SearchException {
        return toCollection(search(Constants.INVALID_ENGINE_INST_ID, query, filters, clazz, start, limit, null), clazz);
    }

    public <T> List<T> query(String query, Map<String, Object> filters, Class<T> clazz, int start, int limit, String orderBy) throws SearchException {
        return toCollection(search(Constants.INVALID_ENGINE_INST_ID, query, filters, clazz, start, limit, orderBy), clazz);
    }

    public <T> List<T> query(String query, Class<T> clazz, int start, int limit) throws SearchException {
        return toCollection(search(Constants.INVALID_ENGINE_INST_ID, query, null, clazz, start, limit, null), clazz);
    }

    public <T> List<T> query(Map<String, Object> filters, Class<T> clazz) throws SearchException {
        return (List<T>) toCollection(search(Constants.INVALID_ENGINE_INST_ID, filters, clazz), clazz);
    }

    public <T> List<T> query(Map<String, Object> filters, Class<T> clazz, int start, int limit) throws SearchException {
        return toCollection(search(Constants.INVALID_ENGINE_INST_ID, filters, clazz, start, limit), clazz);
    }

    public <T> List<T> query(String query, Class<T> clazz) throws SearchException {
        return query(Constants.INVALID_ENGINE_INST_ID, query, clazz, Constants.DEFAULT_OFFSET, Constants.DEFAULT_PAGE_SIZE);
    }

    public <T> List<T> query(long engineId, String query, Class<T> clazz, int start, int limit) throws SearchException {
        return toCollection(search(engineId, query, clazz), clazz);
    }

    public <T> List<T> query(long engineId, Map<String, Object> filters, Class<T> clazz) throws SearchException {
        return toCollection(search(engineId, filters, clazz), clazz);
    }

	// search to get search hits
    public SearchHits search(String query, Class<?> clazz) throws SearchException {
        return search(Constants.INVALID_ENGINE_INST_ID, query, clazz);
    }

    public SearchHits search(String query, List<AttributeFilter> filters, Class<?> clazz, int start, int limit, String orderBy) throws SearchException {
        Map<String, Object> filterMap = new HashMap<>();
        filters.stream().forEach((filter) -> {
            filterMap.put(filter.getAttrName(), filter);
        });
        return search(Constants.INVALID_ENGINE_INST_ID, query, filterMap, clazz, start, limit, orderBy);
    }

    public SearchHits search(String query, Map<String, Object> filters, Class<?> clazz, int start, int limit, String orderBy) throws SearchException {
        return search(Constants.INVALID_ENGINE_INST_ID, query, filters, clazz, start, limit, orderBy);
    }

    public SearchHits search(long engineId, String query, Map<String, Object> filters, Class<?> clazz, int start, int limit, String orderBy) throws SearchException {
        sLogger.log(Level.FINE, "Search {0} with query {1}", new Object[]{clazz.getName(), query});

        SearchableObject so = getSearchableObject(engineId, clazz);
        QueryMetaDataImpl queryMetaData = getQmd(query, filters, so);

        if (orderBy != null) {
            String[] orderByElements = orderBy.split(",");
            String dir = QueryMetaData.ASC;
            if (orderByElements.length == 2) {
                dir = orderByElements[1];
                orderBy = orderByElements[0];
            }
            queryMetaData.setOrderBy(orderBy, dir);
        }

        queryMetaData.setOffset(start);
        queryMetaData.setPageSize(limit);
        return search(queryMetaData, so);
    }

    public SearchHits search(long engineId, String query, Class<?> clazz) throws SearchException {
        return search(engineId, query, null, clazz, this.offset, this.pageSize, null);
    }

    public SearchHits search(QueryMetaData queryMetaData, Class<?> clazz) throws SearchException {
        SearchableObject so = getSearchableObject(Constants.INVALID_ENGINE_INST_ID, clazz);
        return search(queryMetaData, so);
    }

    public QueryMetaData getQmd(String query, Class<?> clazz) {
        SearchableObject so = getSearchableObject(Constants.INVALID_ENGINE_INST_ID, clazz);
        return getQmd(query, so);
    }

    public SearchHits search(Map<String, Object> filters, SearchableObject so) throws SearchException {
        QueryMetaDataImpl queryMetaData = getQmd(filters, so);
        return search(queryMetaData, so);
    }

    public SearchHits search(String query, SearchableObject so) throws SearchException {
        QueryMetaDataImpl queryMetaData = getQmd(query, so);
        return search(queryMetaData, so);
    }

    public SearchHits search(Map<String, Object> filters, Class<?> clazz) throws SearchException {
        SearchableObject so = getSearchableObject(Constants.INVALID_ENGINE_INST_ID, clazz);
        QueryMetaDataImpl queryMetaData = getQmd(filters, so);
        return search(queryMetaData, so);
    }

    public SearchHits search(long engineId, Map<String, Object> filters, Class<?> clazz, int start, int limit) throws SearchException {
        SearchableObject so = getSearchableObject(engineId, clazz);
        QueryMetaDataImpl queryMetaData = getQmd(filters, so);
        if (filters.size() > 0) {
            for (String key : filters.keySet()) {
                Object value = filters.get(key);
                if (value instanceof String) {
                    queryMetaData.setQueryString(value.toString());
                    break;
                }
            }
        }

        queryMetaData.setPageSize(limit);
        queryMetaData.enableFacets(true);
        queryMetaData.setOffset(start);
        return search(queryMetaData, so);
    }

    public SearchHits search(long engineId, Map<String, Object> filters, Class<?> clazz) throws SearchException {
        return search(engineId, filters, clazz, 0, pageSize);
    }

    public SearchHits search(QueryMetaData queryMetaData, SearchableObject so) throws SearchException {
        sLogger.log(Level.FINE, "runQuery {0} with query {1}", new Object[]{so.getName(), queryMetaData});
        queryMetaData.setSOName(so.getName());

        SearchEngine engine = MetaDataManager.getSearchEngine(so.getSearchEngineInstanceId());
        SearchHits hits = engine.getSearcher().search(queryMetaData);
        return hits;
    }

    private AttributeDefinition getAttrDef(DocumentDefinition docDef, String attrName) {
        for (AttributeDefinition attrDef : docDef.getAttrDefs()) {
            if (attrDef.getName().equals(attrName)) {
                return attrDef;
            }
        }
        return null;
    }

    public QueryMetaDataImpl getQmd(String query, Map<String, Object> filters, SearchableObject so) {
        QueryMetaDataImpl queryMetaData = getQmd(filters, so);
        queryMetaData.setQueryString(query);
        return queryMetaData;
    }

    public QueryMetaDataImpl getQmd(Map<String, Object> filters, SearchableObject so) {
        QueryMetaDataImpl queryMetaData = new QueryMetaDataImpl();
        DocumentDefinition docDef = so.getDocumentDef();

        if (filters != null) {
            filters.keySet().stream().forEach((key) -> {
                Object value = filters.get(key);

                if (value instanceof AttributeFilter) {
                    queryMetaData.addFilter((AttributeFilter) value);
                } else {
                    AttributeDefinition fd = getAttrDef(docDef, key);
                    queryMetaData.addFilter(fd.getName(), fd.getDataType(), filters.get(key), Constants.OPERATOR_EQS);
                }
            });
        }

        SearchContext ctx = ContextFactory.getSearchContext();
        ctx.setSearchableObject(so);
        queryMetaData.enableFacets(so.getFacetDefs() != null && so.getFacetDefs().size() > 0);
        String className = so.getName();
        List<SearchGroup> groups = new ArrayList<>();
        groups.add(new SearchGroup(className, so.getSearchEngineInstanceId()));

        queryMetaData.addSearchGroups(groups);
        queryMetaData.setSOName(className);

        queryMetaData.setOffset(offset);
        queryMetaData.setPageSize(pageSize);
        queryMetaData.enableFacets(enableFacet);
        return queryMetaData;
    }

    public QueryMetaDataImpl getQmd(String query, SearchableObject so) {

        QueryMetaDataImpl queryMetaData = new QueryMetaDataImpl();

        String[] filters = query.split(";");
        boolean hasFilters = false;
        for (String filter : filters) {
            String[] filterDetails = filter.split(":");
            if (filterDetails.length > 1) {
                queryMetaData.addFilter(filterDetails[0], null, filterDetails[1], Constants.OPERATOR_EQS);
                hasFilters = true;
            }
        }

        if (!hasFilters) {
            queryMetaData.setQueryString(query);
        }

        SearchContext ctx = ContextFactory.getSearchContext();
        ctx.setSearchableObject(so);
        queryMetaData.enableFacets(so.getFacetDefs() != null && so.getFacetDefs().size() > 0);
        String className = so.getName();

        List<SearchGroup> groups = new ArrayList<>();
        groups.add(new SearchGroup(className, so.getSearchEngineInstanceId()));
        queryMetaData.addSearchGroups(groups);
        queryMetaData.setSOName(className);
        queryMetaData.setOffset(offset);
        queryMetaData.setPageSize(pageSize);
        queryMetaData.enableFacets(enableFacet);
        return queryMetaData;
    }

    public void createObject(String objectName, Map<String, Object> attrValues) {
        try {
            SearchableObject so = MetaDataManager.getSearchableObject(objectName);
            DocumentDefinitionImpl docDef = (DocumentDefinitionImpl) so.getDocumentDef();
            Object object = ClassUtil.create(objectName);
            docDef.assign(attrValues, object);
            insert(object);
        } catch (IndexingException ie) {
            sLogger.log(Level.SEVERE, "Failed to create object {0}", objectName);
        }
    }

    public Object toObject(Document doc, String className, List<String> rules) {
        Object obj = ClassUtil.create(className);
        if (obj != null) {
            DocumentDefinitionImpl docDef = (DocumentDefinitionImpl) doc.getSearchableObject().getDocumentDef();
            docDef.assign(obj, doc, rules);
            if (obj instanceof DataCommon) {
                DataCommon dc = (DataCommon) obj;
                if (dc.getDisplayName() == null || dc.getDisplayName().length() == 0) {
                    dc.setDisplayName(doc.getTitle());
                }
                if (dc.getDesc() == null || dc.getDesc().length() == 0) {
                    dc.setDesc(doc.getContent());
                }
            }
        } else {
            sLogger.log(Level.SEVERE, "Class must have a default constrcutor - {0}", className);
        }
        return obj;
    }

    public Object toObject(Document doc, String className) {
        return toObject(doc, className, null);
    }

    public Object createObject(Document doc, String className) throws IndexingException {
        Object obj = ClassUtil.create(className);
        if (obj != null) {
            SearchableObject so = doc.getSearchableObject();
            DocumentDefinitionImpl docDef = (DocumentDefinitionImpl) so.getDocumentDef();
            docDef.assign(obj, doc);
            docDef.generatePrimaryKey(obj);
            insert(so.getSearchEngineInstanceId(), obj);
        }
        return obj;
    }

    public String toString(IndexableDocument doc) throws IOException {
        XMLWriter writer = new XMLWriter();
        writer.write(doc);
        return writer.getString();
    }

    @SuppressWarnings("unchecked")
    public <T> List<T> toCollection(SearchHits hits, Class<T> clazz) throws SearchException {
        if (hits == null) {
            return Collections.emptyList();
        }

        ArrayList<T> list = new ArrayList<>();
        for (int i = 0; i < hits.getCount(); i++) {
            T obj = (T) toObject(hits.getDocument(i), clazz.getName());
            if (obj != null) {
                list.add(obj);
            }
        }
        return list;
    }

    public static SearchableObject getSearchableObject(long engineInstId, Class<?> clazz) {
        String className = clazz.getName();
        SearchableObject so = MetaDataManager.getSearchableObject(engineInstId, className);
        Configurable config = (Configurable) MetaDataManager.getConfig();
        if (so == null) {
            so = new SearchableDataObject(clazz);
            so = config.addSearchableObjectToEngineInstance(so, engineInstId);
        }
        return so;
    }

    public long indexDocuments(String xml) {
        XMLReader reader = new XMLReader();
        List<IndexableDocument> docs = reader.read(xml);
        SearchContext searchContext = ContextFactory.getSearchContext();
        long i = 0;
        Indexer indexer = null;
        for (IndexableDocument doc : docs) {
            SearchableObject object = doc.getSearchableObject();
            if (indexer == null) {
                searchContext.setSearchableObject(object);
                indexer = MetaDataManager.getSearchEngine(object.getSearchEngineInstanceId()).getIndexer();
            }
            try {
                indexer.indexDocument(doc);
                i++;
            } catch (IndexingException e) {
                sLogger.log(Level.WARNING, "Failed to index {0}", xml);
            }
        }
        if (indexer != null) {
            try {
                indexer.close();
            } catch (IndexingException e) {
                sLogger.severe("Failed to close the indexer");
            }
        }
        return i;
    }

    public void setStart(int start) {
        this.offset = start;
    }

    public int getStart() {
        return offset;
    }

    public void setEnableFacet(boolean enableFacet) {
        this.enableFacet = enableFacet;
    }

    public boolean isEnableFacet() {
        return enableFacet;
    }

    public void setPageSize(int mPageSize) {
        this.pageSize = mPageSize;
    }

    public int getPageSize() {
        return pageSize;
    }
}
