package org.sixstreams.search.meta.xml.impl;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;

import java.net.MalformedURLException;
import java.net.URL;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

import org.sixstreams.Constants;
import org.sixstreams.search.RuntimeSearchException;
import org.sixstreams.search.crawl.scheduler.Schedule;
import org.sixstreams.search.facet.FacetDef;
import org.sixstreams.search.meta.AttributeDefImpl;
import org.sixstreams.search.meta.AttributeDefinition;
import org.sixstreams.search.meta.DocumentDefinition;
import org.sixstreams.search.meta.MetaEngineInstance;
import org.sixstreams.search.meta.ObjectExtension;
import org.sixstreams.search.meta.SearchEngineType;
import org.sixstreams.search.meta.SearchPluginDef;
import org.sixstreams.search.meta.SearchableGroup;
import org.sixstreams.search.meta.SearchableObject;
import org.sixstreams.search.meta.action.SearchResultActionDef;
import org.sixstreams.search.util.ClassUtil;
import org.sixstreams.search.util.ContextFactory;
import org.sixstreams.search.util.XMLUtil;


public class FileHandler
{
   protected static Logger sLogger = Logger.getLogger(FileHandler.class.getName());
   private final static String TRUE = "true";


   private final static String ENGINE_IMPL_CLASS = "implClass";
   private final static String TARGET = "target";

   //attributes

   private final static String NAME = "name";
   private final static String ID = "id";
   private final static String EID = "eid";
   private final static String ENGINE_TYPE_ID = "engineTypeId";
   private final static String ENGINE_TYPE = "engineType";
   private final static String DISPLAY_NAME = "displayName";
   private final static String SCOPE = "scope";
   private final static String APPLICATION_ID = "applid";
   private final static String IS_DEPLOYED = "isDeployed";
   private final static String IS_ACTIVATED = "isActivated";

   private final static String DATA_TYPE = "dataType";
   private final static String SEQUENCE = "sequence";

   private final static String IS_SECURE = "isSecure";
   private final static String IS_STORED = "isStored";
   private final static String TYPE = "type";
   private final static String IS_DEFAULT = "isDefault";

   private final static String TITLE = "title";
   private final static String PASSWORD = "password";

   private static final String NEW_LINE = "\n";

   private XmlConfiguration configuration;
   //this constructor should only be used by MetaDataManager, you should not
   //manually create this object

   public FileHandler(XmlConfiguration configuration)
   {
      this.configuration = configuration;
      filename = this.configuration.getLocation();
   }

   String engines2String(List<MetaEngineInstance> engines)
   {
      if (engines == null)
      {
         throw new IllegalArgumentException("Failed to serialize a null engine instances list or a null search groups map!");
      }
      StringBuffer result = new StringBuffer("<?xml version=\"1.0\"?>").append(NEW_LINE);
      result.append("<sixstreams>").append(NEW_LINE);

      Map params = configuration.getParameters();

      if (params != null && !params.isEmpty())
      {
         result.append("<params>");
         for (Object key: params.keySet())
         {
            result.append("<param name=\"").append(key).append("\">");
            result.append("<![CDATA[").append(params.get(key)).append("]]>");
            result.append("</param> ").append(NEW_LINE);
         }
         result.append("</params>").append(NEW_LINE);
      }

      result.append(engineTypes2String(configuration.getSearchEngineTypes()));

      result.append(objects2String(configuration.getSearchableObjects()));

      result.append("<engineInstances>").append(NEW_LINE);

      for (MetaEngineInstance engine: engines)
      {
         result.append("<engineInstance name=\"").append(engine.getName()).append("\"");
         result.append(" id=\"").append(engine.getId()).append("\"");
         result.append(" engineTypeId=\"").append(engine.getEngineTypeId()).append("\"");
         result.append(" engineType=\"").append(engine.getEngineType()).append("\"");
         result.append(" displayName=\"").append(engine.getDisplayName()).append("\" > ").append(NEW_LINE);

         List<SearchableGroup> sgs = configuration.getSearchableGroups(engine.getId());
         if (sgs != null && !sgs.isEmpty())
         {
            result.append("<categories>").append(NEW_LINE);
            for (SearchableGroup sg: sgs)
            {
               result.append("<category name=\"").append(sg.getName()).append("\"");
               result.append(" eid=\"").append(sg.getEngineInstanceId()).append("\"");
               result.append(" id=\"").append(sg.getId()).append("\"");

               result.append(" displayName=\"").append(sg.getDisplayName()).append("\" ");
               result.append(" isDeployed=\"").append(sg.isDeployed()).append("\" ");
               result.append(" scope=\"").append(sg.getScope()).append("\" ");

               result.append(" >").append(NEW_LINE);

               List<String> objects = sg.getObjectNames();
               if (objects != null && objects.size() != 0)
               {
                  result.append("<searchableObjects>").append(NEW_LINE);
                  for (String so: objects)
                  {
                     result.append("<searchableObject name=\"").append(so).append("\"");
                     //result.append(" id=\"").append(so.getId()).append("\"");
                     result.append(" /> ").append(NEW_LINE);
                  }
                  result.append("</searchableObjects>").append(NEW_LINE);
               }

               result.append("</category>").append(NEW_LINE);
            }
            result.append("</categories>").append(NEW_LINE);
         }


         Collection<Schedule> schds = configuration.getSchedules(engine.getId());
         if (schds != null && !schds.isEmpty())
         {
            result.append("<schedules>");
            for (Schedule schd: schds)
            {
               result.append("<schedule name=\"").append(schd.getName()).append("\"");
               result.append(" eid=\"").append(schd.getEngineInstanceId()).append("\"");
               result.append(" startTime=\"").append(schd.getStartAt()).append("\"");
               result.append(" isDeployed=\"").append(schd.isDeployed()).append("\"");
               result.append(" id=\"").append(schd.getId()).append("\"");
               result.append(" >").append(NEW_LINE);
               List<SearchableObject> objects = schd.getSearchableObjects();
               if (objects != null && objects.size() != 0)
               {
                  result.append("<searchableObjects>").append(NEW_LINE);
                  for (SearchableObject so: objects)
                  {
                     result.append("<searchableObject name=\"").append(so.getName()).append("\"");
                     // result.append(" id=\"").append(so.getId()).append("\"");
                     result.append(" /> ").append(NEW_LINE);
                  }
                  result.append("</searchableObjects>").append(NEW_LINE);
               }
               result.append("</schedule>").append(NEW_LINE);
            }
            result.append("</schedules>").append(NEW_LINE);
         }

         params = engine.getParameters();

         if (params != null && !params.isEmpty())
         {
            result.append("<params>");
            for (Object obj: params.keySet())
            {
               String entry = (String) obj;
               if (entry.endsWith(PASSWORD))
               {
                  //CryptoService.savePassword(engine.getId(), params.get(entry));
               }
               else
               {
                  result.append("<param name=\"").append(entry).append("\">");
                  result.append("<![CDATA[").append(params.get(entry)).append("]]>");
                  result.append("</param> ").append(NEW_LINE);
               }
            }
            result.append("</params>").append(NEW_LINE);
         }
         result.append("</engineInstance>").append(NEW_LINE);
      }
      result.append("</engineInstances>").append(NEW_LINE);
      result.append("</sixstreams>");
      return result.toString();
   }

   private String engineTypes2String(List<SearchEngineType> searchEngineTypes)
   {
      StringBuffer result = new StringBuffer();
      if (searchEngineTypes != null && !searchEngineTypes.isEmpty())
      {
         result.append("<searchEngineTypes>").append(NEW_LINE);

         for (SearchEngineType searchEngineType: searchEngineTypes)
         {
            result.append("<searchEngineType name=\"").append(searchEngineType.getName()).append("\"");
            result.append(" id=\"").append(searchEngineType.getId()).append("\"");
            result.append(" implClass=\"").append(searchEngineType.getEngineImplType()).append("\" ");
            result.append(" > ").append(NEW_LINE);

            Map<String, String> params = searchEngineType.getParameters();
            if (params != null)
            {
               result.append("<params>");
               for (String key: params.keySet())
               {
                  result.append("<param name=\"").append(key).append("\">");
                  result.append("<![CDATA[").append(params.get(key)).append("]]>");
                  result.append("</param> ").append(NEW_LINE);
               }
               result.append("</params>").append(NEW_LINE);
            }
            result.append("</searchEngineType>").append(NEW_LINE);
         }
         result.append("</searchEngineTypes>").append(NEW_LINE);
      }
      return result.toString();
   }

   private StringBuffer facet2String(FacetDef facetDef)
   {
      StringBuffer result = new StringBuffer();
      result.append("<facetDef name=\"").append(facetDef.getName()).append("\"");
      result.append(" attrName=\"").append(facetDef.getAttrName()).append("\"");
      result.append(" displayName=\"").append(facetDef.getDisplayName()).append("\" ");
      result.append(" > ").append(NEW_LINE);
      if (facetDef.getChildDef() != null)
      {
         result.append("<facetDefs>");
         result.append(facet2String(facetDef.getChildDef()));
         result.append("</facetDef>").append(NEW_LINE);
      }

      return result;
   }

   private StringBuffer facets2String(SearchableObject so)
   {

      StringBuffer result = new StringBuffer();
      //TODO, we dont want to write facet def here
      try
      {
         List<FacetDef> facetDefs = so.getFacetDefs();
         if (facetDefs != null && facetDefs.size() > 0 && false)
         {
            result.append("<facetDefs>");
            for (FacetDef facetdef: facetDefs)
            {
               result.append(facet2String(facetdef));
            }
            result.append("</facetDefs>").append(NEW_LINE);
         }
      }
      catch (Throwable e)
      {
         e.printStackTrace();
      }
      return result;
   }

   private String objects2String(List<SearchableObject> objects)
   {
      StringBuffer result = new StringBuffer();
      if (objects != null && !objects.isEmpty())
      {
         result.append("<searchableObjects>").append(NEW_LINE);
         List<SearchableObject> clonedList = new ArrayList<SearchableObject>(objects);
         for (SearchableObject so: clonedList)
         {
            // mConfiguration.registerSearchableObject(so.getName(), so.getDisplayName(), so.getName());
            result.append("<searchableObject name=\"").append(so.getName()).append("\"");
            result.append(" id=\"").append(so.getId()).append("\"");
            result.append(" eid=\"").append(so.getSearchEngineInstanceId()).append("\"");
            result.append(" implClass=\"").append(so.getClass().getName()).append("\"");
            result.append(" displayName=\"").append(so.getDisplayName()).append("\" ");
            result.append(" isActivated=\"").append(so.isActive()).append("\" ");
            result.append(" isDeployed=\"").append(so.isDeployed()).append("\" ");
            result.append(" > ").append(NEW_LINE);

            Collection<AttributeDefinition> fields =
               so.getDocumentDef() != null? so.getDocumentDef().getAttrDefs(): null;
            if (fields != null)
            {
               result.append("<attrDefs>");
               for (AttributeDefinition attrDef: fields)
               {
                  if (!isReservedAttr(attrDef.getName()))
                  {
                     result.append("<attrDef name=\"").append(attrDef.getName()).append("\"");
                     result.append(" dataType=\"").append(attrDef.getDataType()).append("\" ");
                     result.append(" isStored=\"").append(attrDef.isStored()).append("\" ");
                     result.append(" isSecure=\"").append(attrDef.isSecure()).append("\" ");
                     result.append(" sequence=\"").append(attrDef.getSequence()).append("\" ");
                     result.append(" > ");
                     result.append("</attrDef>").append(NEW_LINE);
                  }
               }
               result.append("</attrDefs>").append(NEW_LINE);
            }

            result.append("<title>").append(NEW_LINE);
            String titleStr = so.getTitle() == null? "": so.getTitle();
            result.append("<![CDATA[").append(titleStr).append("]]>").append(NEW_LINE);
            result.append("</title> ").append(NEW_LINE);
            result.append("<body>").append(NEW_LINE);
            titleStr = so.getContent() == null? "": so.getContent();
            result.append("<![CDATA[").append(titleStr).append("]]>").append(NEW_LINE);
            result.append("</body> ").append(NEW_LINE);
            result.append("<keywords>").append(NEW_LINE);
            titleStr = so.getKeywords() == null? "": so.getKeywords();
            result.append("<![CDATA[").append(titleStr).append("]]>").append(NEW_LINE);
            result.append("</keywords> ").append(NEW_LINE);

            Map<String, String> soProperties = XmlConfiguration.getCustomProperties(so);
            if (soProperties != null && soProperties.size() > 0)
            {
               result.append("<params>");
               for (Object key: soProperties.keySet())
               {
                  String value = soProperties.get(key);
                  if (value != null)
                  {
                     result.append("<param name=\"").append(key).append("\">").append(NEW_LINE);
                     result.append("<![CDATA[").append(value).append("]]>").append(NEW_LINE);
                     result.append("</param> ").append(NEW_LINE);
                  }
               }
               result.append("</params>").append(NEW_LINE);
            }

            ObjectExtension os = configuration.getObjectExtension(so);
            result.append("<templates>").append(NEW_LINE);
            titleStr = os.getTemplate() == null? "": os.getTemplate();
            result.append("<![CDATA[").append(titleStr).append("]]>").append(NEW_LINE);
            result.append("</templates> ").append(NEW_LINE);

            result.append("<context>").append(NEW_LINE);
            titleStr = os.getContext() == null? "": os.getContext();
            result.append("<![CDATA[").append(titleStr).append("]]>").append(NEW_LINE);
            result.append("</context> ").append(NEW_LINE);

            result.append("<relatedObjects>").append(NEW_LINE);
            titleStr = os.getRelatedObjects() == null? "": os.getRelatedObjects();
            result.append("<![CDATA[").append(titleStr).append("]]>").append(NEW_LINE);
            result.append("</relatedObjects> ").append(NEW_LINE);

            SearchPluginDef def = so.getSearchPlugIn();
            if (def != null)
            {
               result.append("<plugin name=\"").append(def.getClassName()).append("\">");
               Map paramMaps = def.getParametersMap();
               if (paramMaps != null && paramMaps.size() > 0)
               {
                  result.append("<params>");
                  for (Object entry: paramMaps.keySet())
                  {
                     result.append("<param name=\"").append(entry).append("\">").append(NEW_LINE);
                     result.append("<![CDATA[").append(paramMaps.get(entry)).append("]]>").append(NEW_LINE);
                     result.append("</param> ").append(NEW_LINE);
                  }
                  result.append("</params>").append(NEW_LINE);
               }
               result.append("</plugin>");
            }


            result.append(facets2String(so));

            if (so.getSearchActions() != null)
            {
               result.append("<actionDefs>");
               for (SearchResultActionDef facetdef: so.getSearchActions())
               {
                  result.append("<actionDef name=\"").append(facetdef.getName()).append("\"");
                  result.append(" isDefault=\"").append(facetdef.isDefaultAction()).append("\" ");
                  result.append(" type=\"").append(facetdef.getType()).append("\" ");
                  result.append(" > ").append(NEW_LINE);
                  result.append("<target><![CDATA[").append(facetdef.getTarget()).append("]]></target>").append(NEW_LINE);
                  result.append("<title><![CDATA[").append(facetdef.getTitle()).append("]]></title>").append(NEW_LINE);
                  if (facetdef.getParamMap() != null)
                  {
                     result.append("<params>");
                     for (Object entry: facetdef.getParamMap().keySet())
                     {
                        result.append("<param name=\"").append(entry).append("\">").append(NEW_LINE);
                        result.append("<![CDATA[").append(facetdef.getParamMap().get(entry)).append("]]>").append(NEW_LINE);
                        result.append("</param> ").append(NEW_LINE);
                     }
                     result.append("</params>").append(NEW_LINE);
                  }
                  result.append("</actionDef>").append(NEW_LINE);
               }
               result.append("</actionDefs>").append(NEW_LINE);
            }
            result.append("</searchableObject>").append(NEW_LINE);
         }
         result.append("</searchableObjects>").append(NEW_LINE);
      }
      return result.toString();
   }

   boolean isReservedAttr(String attrName)
   {
      return "DEFAULT_ACL_KEY".equals(attrName) || attrName.startsWith("TAGS") ||
         attrName.startsWith(Constants.SO_NAME);
   }

   public AttributeDefinition getAttrDef(DocumentDefinition docDef, String name)
   {
      for (AttributeDefinition field: docDef.getAttrDefs())
      {
         if (field.getName().equals(name))
         {
            return field;
         }
      }
      return null;
   }

   private List<?> getList(Object value)
   {
      if (value == null)
      {
         return Collections.emptyList();
      }

      if (value instanceof List)
      {
         return (List<?>) value;
      }
      else
      {
         List<Object> list = new ArrayList<Object>();
         list.add(value);
         return list;
      }

   }

   private void newEngineType(Map engineTypeMap)
   {
      String id = (String) engineTypeMap.get(ID);
      SearchEngineType engineType = new SearchEngineType(Long.valueOf(id));
      String name = (String) engineTypeMap.get(NAME);
      String implClass = (String) engineTypeMap.get(ENGINE_IMPL_CLASS);
      engineType.setEngineImplType(implClass);
      engineType.setName(name);
      configuration.getSearchEngineTypes().add(engineType);

      List<?> params = getList(engineTypeMap.get("params.param"));

      for (Object param: params)
      {
         String key = (String) ((Map) param).get(NAME);
         String value = (String) ((Map) param).get(XMLUtil.TEXT_VALUE_KEY);
         engineType.addParameter(key, value);
      }
   }

   private void newEngine(Map engineMap)
   {
      MetaEngineInstance engine = new MetaEngineInstance();

      String name = (String) engineMap.get(NAME);
      String id = (String) engineMap.get(ID);
      String typeId = (String) engineMap.get(ENGINE_TYPE_ID);
      String engineType = (String) engineMap.get(ENGINE_TYPE);
      String displayName = (String) engineMap.get(DISPLAY_NAME);

      engine.setName(name);
      engine.setEngineType(engineType);
      engine.setEngineTypeId(Long.valueOf(typeId));
      engine.setId(Long.valueOf(id));

      configuration.getEngineInstances().add(engine);
      List categories = getList(engineMap.get("categories.category"));

      for (Object category: categories)
      {
         SearchableGroup sg = newSearchableGroup((Map) category);
         sg.setEngineInstanceId(engine.getId());
         configuration.getSearchableGroups().add(sg);
      }

      List schedules = getList(engineMap.get("schedules.schedule"));
      for (Object schedule: schedules)
      {
         Schedule schd = newSchedule((Map) schedule);
         schd.setEngineInstanceId(engine.getId());
         configuration.getSchedules().add(schd);
      }

      List params = getList(engineMap.get("params.param"));

      for (Object param: params)
      {
         String key = (String) ((Map) param).get(NAME);
         String value = (String) ((Map) param).get(XMLUtil.TEXT_VALUE_KEY);
         engine.getParameters().put(key, value);
      }

   }

   private Schedule newSchedule(Map scheduleMap)
   {
      String name = (String) scheduleMap.get(NAME);
      Schedule schedule = new Schedule();
      schedule.setName(name);
      String id = (String) scheduleMap.get(ID);
      String deployed = (String) scheduleMap.get(IS_DEPLOYED);
      String displayName = (String) scheduleMap.get(DISPLAY_NAME);
      long engineId = Long.valueOf((String) scheduleMap.get(EID));
      schedule.setDisplayName(displayName);
      schedule.setDeployed("true".equals(deployed));
      schedule.setName(name);
      schedule.setId(id);
      schedule.setEngineInstanceId(engineId);
      List objects = getList(scheduleMap.get("searchableObjects.searchableObject"));
      for (Object object: objects)
      {
         String objName = (String) ((Map) object).get(NAME);
         schedule.addObject(objName);
      }
      return schedule;
   }

   private SearchableGroup newSearchableGroup(Map groupMap)
   {
      String name = (String) groupMap.get(NAME);
      SearchableGroup group = new SearchableGroup(name);

      String id = (String) groupMap.get(ID);
      String scope = (String) groupMap.get(SCOPE);
      String deployed = (String) groupMap.get(IS_DEPLOYED);
      String displayName = (String) groupMap.get(DISPLAY_NAME);

      long seiId = Long.valueOf((String) groupMap.get(EID));
      group.setId(id);
      group.setScope(scope);
      group.setDeployed("true".equals(deployed));
      group.setEngineInstanceId(seiId);
      List objects = getList(groupMap.get("searchableObjects.searchableObject"));

      for (Object object: objects)
      {
         String objName = (String) ((Map) object).get(NAME);
         group.addSearchableObject(objName);
      }
      return group;
   }

   private void newSearchObject(Map<String, String> objectMap)
   {
      String name = (String) objectMap.get(NAME);
      String displayName = (String) objectMap.get(DISPLAY_NAME);
      long eid = Long.valueOf((String) objectMap.get(EID));

      String implClass = (String) objectMap.get(ENGINE_IMPL_CLASS);

      if (implClass == null || implClass.equals(SearchableObject.class.getName()))
      {
         implClass = name;
      }

      SearchableObject object = configuration.getSearchableObject(eid, name);
      if (object == null)
      {
         object = configuration.createSearchableObject(Long.valueOf(eid), name, implClass);
         if (object == null)
         {
            return;
         }
      }


      //customization allowed only for  object assigned to an engine
      if (eid != -1)
      {
         String id = (String) objectMap.get(ID);
         String deployed = (String) objectMap.get(IS_DEPLOYED);
         String applId = (String) objectMap.get(APPLICATION_ID);
         String activated = (String) objectMap.get(IS_ACTIVATED);

         object.setId(id);
         object.setDeployed("true".equals(deployed));
         object.setApplId(applId);
        
         object.setActive("true".equals(activated));
         object.setSearchEngineInstanceId(Long.valueOf(eid));

         String title = (String) objectMap.get("title.textValue");
         String content = (String) objectMap.get("body.textValue");
         String keywords = (String) objectMap.get("keyworkds.textValue");

         List objCustomizeParams = getList(objectMap.get("params.param"));
         if (title != null)
         {
            object.setTitle(title);
         }
         if (keywords != null)
         {
            object.setKeywords(keywords);
         }
         if (content != null)
         {
            object.setContent(content);
         }

         if (objCustomizeParams != null)
         {
            for (Object param: objCustomizeParams)
            {
               String key = (String) ((Map) param).get(NAME);
               String value = (String) ((Map) param).get(XMLUtil.TEXT_VALUE_KEY);
               object.setProperty(key, value);
            }
         }

         ObjectExtension se = configuration.getObjectExtension(object);
         String context = (String) objectMap.get("context.textValue");
         String templates = (String) objectMap.get("templates.textValue");
         String relatedObjects = (String) objectMap.get("relatedObjects.textValue");
         se.setContext(context);
         se.setTemplate(templates);
         se.setRelatedObjects(relatedObjects);

         List attrDefs = getList(objectMap.get("attrDefs.attrDef"));

         if (attrDefs != null)
         {
            DocumentDefinition docDef = object.getDocumentDef();
            if (docDef != null)
            {
               //what we do

               for (Object param: attrDefs)
               {
                  Map attrDefMap = (Map) param;
                  name = (String) attrDefMap.get(NAME);

                  //check if binding is still available from VO definition

                  String dataType = (String) attrDefMap.get(DATA_TYPE);
                  boolean stored = TRUE.equals(attrDefMap.get(IS_STORED));
                  boolean secure = TRUE.equals(attrDefMap.get(IS_SECURE));
                  String seq = (String) attrDefMap.get(SEQUENCE);

                  AttributeDefImpl attrDef = (AttributeDefImpl) docDef.getAttrDefByName(name);
                  //only update field def, we do not add new ones from xml file
                  //so that we can be in synch with vo definition
                  if (attrDef != null)
                  {
                     attrDef.setStored(stored);
                     //TODO attrDef.setSecure(secure); we dont want to override security here
                     attrDef.setDataType(dataType);

                     if (seq != null)
                     {
                        attrDef.setSeqneuce(Integer.valueOf(seq));
                     }
                  }

               }
            }
            else
            {
               System.err.println("Failed to get doc def for " + name);
            }
         }

         List actionDefs = getList(objectMap.get("actionDefs.actionDef"));
         if (actionDefs != null)
         {
            SearchResultActionDef[] defs = new SearchResultActionDef[actionDefs.size()];
            int i = 0;

            for (Object actionDef: actionDefs)
            {
               Map actionDefMap = (Map) actionDef;
               name = (String) actionDefMap.get(NAME + "." + XMLUtil.TEXT_VALUE_KEY);
               boolean defaultAction = TRUE.equals(actionDefMap.get(IS_DEFAULT + "." + XMLUtil.TEXT_VALUE_KEY));
               title = (String) actionDefMap.get(TITLE + "." + XMLUtil.TEXT_VALUE_KEY);
               String target = (String) actionDefMap.get(TARGET + "." + XMLUtil.TEXT_VALUE_KEY);
               String type = (String) actionDefMap.get(TYPE + "." + XMLUtil.TEXT_VALUE_KEY);

               List params = getList(objectMap.get("params.param"));

               Map<String, Object> actionParams = new HashMap<String, Object>();
               if (params != null)
               {

                  for (Object param: params)
                  {
                     String key = (String) ((Map) param).get(NAME);
                     String value = (String) ((Map) param).get(XMLUtil.TEXT_VALUE_KEY);
                     actionParams.put(key, value);
                  }
               }
               defs[i++] = new SearchResultActionDef(name, title, type, target, defaultAction, actionParams);
            }
            //TODO update
            //object.setSearchActions(defs);
         }

         List facetDefs = getList(objectMap.get("facetDefs.facetDef"));
         if (facetDefs != null)
         {
            for (Object param: attrDefs)
            {
               String key = (String) ((Map) param).get(NAME);
               String value = (String) ((Map) param).get(XMLUtil.TEXT_VALUE_KEY);
            }
         }
      }
      configuration.getSearchableObjects().add(object);
   }

   public void reload()
   {
      URL url = null;
      if (filename != null)
      {
         File file = new File(filename);
         if (file.exists())
         {
            try
            {
               url = new URL("file://" + filename);
               sLogger.info("Load from configuration file " + filename);
            }
            catch (MalformedURLException murle)
            {
               sLogger.log(Level.WARNING, "Failed to load " + filename, murle);
            }
         }
         else
         {
            sLogger.info("Configuration file " + filename + " does not exist");
         }
      }

      if (url == null)
      {
         url = ClassUtil.getResourceUrl("sixstreams.xml");
         sLogger.info("Load sixstreams.xcfg from class path.");
      }

      if (url == null)
      {
         sLogger.info("Failed to load configuration file " + filename);
         return;
      }

      Map map = XMLUtil.toHashMap(url);
      List engines = getList(map.get("sixstreams.engineInstances.engineInstance"));
      List searchableObjects = getList(map.get("sixstreams.searchableObjects.searchableObject"));
      List engineTypes = getList(map.get("sixstreams.searchEngineTypes.searchEngineType"));
      for (Object engineType: engineTypes)
      {
         newEngineType((Map) engineType);
      }

      for (Object engine: engines)
      {
         newEngine((Map) engine);
      }

      for (Object searchableObject: searchableObjects)
      {
         newSearchObject((Map) searchableObject);
      }
   }

   public void save()
   {
      if (filename == null)
      {
         //we can not write
         return;
      }
      String confurationString = engines2String(configuration.getEngineInstances());
      File file = new File(filename);
      try
      {
         if (!file.exists())
         {
            if (file.getParent() != null)
            {
               File path = new File(file.getParent());
               if (!path.exists())
               {
                  path.mkdirs();
               }
            }
            file.createNewFile();
         }

         FileWriter fos = new FileWriter(file);
         BufferedWriter bw = new BufferedWriter(fos);
         bw.write(confurationString, 0, confurationString.length());
         bw.flush();
         fos.flush();
         fos.close();
      }
      catch (IOException e)
      {
         throw new RuntimeSearchException("Failed to write configuration file " + filename, e);
      }
   }

   private String filename = null;
}
