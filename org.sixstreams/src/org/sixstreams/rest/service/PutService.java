package org.sixstreams.rest.service;

import java.util.logging.Level;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.io.IOUtils;
import org.sixstreams.Constants;
import org.sixstreams.rest.DefaultService;
import org.sixstreams.rest.IdObject;
import org.sixstreams.rest.RestfulException;
import org.sixstreams.rest.SecurityService;
import org.sixstreams.search.SearchException;
import org.sixstreams.search.data.PersistenceManager;
import org.sixstreams.search.util.ClassUtil;
import org.sixstreams.social.Person;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;

/**
 * UPDATE
 *
 * Entity http://hostname:port/contextPath/objectType/objectId e.g.
 * http://localhost:8080/sixstreams/com.iswim.model.Meet/234123128
 *
 * method=PUT {name:"junior-olympic-2012-10", date:"08-12-2012", city:"San
 * Ramon"}
 *
 * returns the json object with updated values. The server can deny an update
 * for a given attribute
 *
 * http://hostname:port/contextPath/objectType/objectId/content e.g.
 * http://localhost:8080/sixstreams/org.mypacswim.User/test.again@mypacswim.com
 *
 * method=PUT content
 *
 * returns json object of the given type created with id
 *
 * options x-sixstreams-
 *
 * @author anpwang
 *
 */
public class PutService extends DefaultService {

    protected Object getObject(HttpServletRequest request) {
        String resourceName = rd.getResource();// object name
        String resourceId = rd.getResourceId();// id, definition, list, or
        // primarykey
        Class<?> objectClass = ClassUtil.getClass(resourceName);
        if (objectClass != null && resourceId != null) {
            try {
                PersistenceManager pm = new PersistenceManager();
                return pm.getObjectById(resourceId, objectClass);
            } catch (SearchException e) {
                throw new RestfulException(500, "Failed to get  " + resourceName + Constants.PATH_SEPARATOR + resourceId, "defaultService");
            }
        } else {
            throw new RestfulException(400, "Failed to load  " + resourceName + Constants.PATH_SEPARATOR + resourceId, "defaultService");
        }
    }

    public boolean performService(HttpServletRequest request, HttpServletResponse response) {
        parseRequest(request, response);
        String resourceName = rd.getResource();// object name
        String resourceId = rd.getResourceId();// id, definition, list, or

        if (resourceName == null || resourceId == null) {
            throw new RestfulException(400, "Type and Id are required", Constants.ACTION_UPDATE);
        }

        try {
            IdObject object = (IdObject) getObject(request);

            if (object == null) {
                throw new RestfulException(404, "Failed to find object to update", Constants.ACTION_UPDATE);
            }

            String contentType = request.getContentType();
            if (contentType.contains(Constants.CONTENT_TYPE_JSON)) {

                String json = IOUtils.toString(request.getInputStream());

                Gson gson = new GsonBuilder().setDateFormat(Constants.DATE_TIME_FORMAT).create();
                IdObject obj = (IdObject) gson.fromJson(json, ClassUtil.getClass(resourceName));

                // merge object and obj
                obj.setId(rd.getResourceId());
                ClassUtil.patch(object, obj);
                PersistenceManager pm = new PersistenceManager();
                if (object.getCreatedByName() == null && object.getCreatedBy() != null) {
                    Person person = (Person) pm.getObjectById(object.getCreatedBy(), SecurityService.getProfileClass());
                    if (person != null) {
                        object.setCreatedByName(person.getFirstName() + " " + person.getLastName());
                    }
                }
                pm.update(object);
                recordActivity(pm, obj, Constants.ACTION_UPDATE);
                response.getWriter().write(writer.toString(object).toString());
            }
            return true;
        } catch (RestfulException re) {
            throw re;
        } catch (Exception e) {
            sLogger.log(Level.SEVERE, "Failed to update item", e);
            throw new RestfulException(500, "Failed to update item", Constants.ACTION_UPDATE);
        }
    }
}
