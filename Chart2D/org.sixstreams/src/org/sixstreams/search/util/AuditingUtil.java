package org.sixstreams.search.util;

import java.util.HashMap;
import java.util.Map;

public class AuditingUtil
{
   static Map<String, AuditingUtil> actors = new HashMap<String, AuditingUtil>();
   private long started;
   private long visited;

   public static void audit(String actor, String message)
   {
      AuditingUtil audit = actors.get(actor);
      long timeSinceVisited = 0;
      long timeSinceStarted = 0;
      if (audit == null)
      {
         audit = new AuditingUtil();
         audit.started = System.currentTimeMillis();
         audit.visited = audit.started;
         actors.put(actor, audit);
      }
      else
      {
         timeSinceStarted = System.currentTimeMillis() - audit.started;
         timeSinceVisited = System.currentTimeMillis() - audit.visited;
         audit.visited = System.currentTimeMillis();
      }

      if (timeSinceStarted != 0 && timeSinceVisited != 0)
      {
         System.err.println(actor + ":" + message + " " + timeSinceVisited + " in " + timeSinceStarted);
      }
      else if (timeSinceStarted != 0)
      {
         System.err.println(actor + ":" + message + " in " + timeSinceStarted);
      }
      else
      {
         System.err.println(actor + ":" + message);
      }
   }

   public static void end(String actor, String message)
   {
      audit(actor, message);
      actors.remove(actor);
   }
}
