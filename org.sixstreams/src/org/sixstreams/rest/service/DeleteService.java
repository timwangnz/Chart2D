package org.sixstreams.rest.service;

import java.util.logging.Level;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.sixstreams.Constants;
import org.sixstreams.rest.IdObject;
import org.sixstreams.rest.RestBaseResource;
import org.sixstreams.rest.RestfulException;
import org.sixstreams.rest.StorageServiceFactory;
import org.sixstreams.search.data.PersistenceManager;
import org.sixstreams.social.SocialAction;

/**
 * DELETE
 *
 * http://hostname:port/contextPath/objectType/objectId e.g.
 * http://localhost:8080/sixstreams/org.mypacswim.User/test.again@mypacswim.com
 *
 * method=DELETE options x-sixstreams-
 *
 * @author anpwang
 *
 */
public class DeleteService extends PutService {

    public boolean performService(HttpServletRequest request, HttpServletResponse response) {
        try {
            parseRequest(request, response);

            IdObject object = (IdObject) getObject(request);
            if (object == null) {
                //throw new RestfulException(404, "Failed to find object to delete", Constants.ACTION_DELETE);
                return true;
            }

            boolean hasResourceDeleted = true;
            if (object instanceof RestBaseResource) {
                hasResourceDeleted = StorageServiceFactory.getService().delete((RestBaseResource) object);
            }
            if (hasResourceDeleted) {
                PersistenceManager pm = new PersistenceManager();
                pm.delete(object);
                if (object instanceof SocialAction) {
                    ((SocialAction) object).onDelete();
                }
                response.getWriter().write(writer.toString(object).toString());
            }

            if (!hasResourceDeleted) {
                throw new RestfulException(500, "Failed to delete resource", Constants.ACTION_DELETE);
            }

            return true;
        } catch (RestfulException re) {
            throw re;
        } catch (Exception e) {
            sLogger.log(Level.SEVERE, "Failed to delete items", e);
            throw new RestfulException(500, "Failed to delete items", Constants.ACTION_DELETE);
        }
    }
}
