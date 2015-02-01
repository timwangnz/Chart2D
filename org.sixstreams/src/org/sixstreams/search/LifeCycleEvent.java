package org.sixstreams.search;

import java.util.HashMap;

/**
 * A lifecycle event is emitted at various stages of processing a document.
 * Application developers can intercept these events by registering an event
 * listener.
 *
 * These events are not searchable object specific, instead they are meant for
 * application developers to intercept the workflow of crawl/query process for
 * the purpose of document maninpuation, interrupt, and auditing. Each event has
 * a type, phase as well as owner object. The owner object can be different at
 * different stage, and it is upto the listener to use these information to
 * perform their own logic.
 *
 * One can register one or more event listeners, there is no particular orders
 * in terms of execution of these listeners.
 *
 * Currently the following phases defined for lifecycle events. Retreive Process
 * Index
 *
 */
public class LifeCycleEvent // extends HashMap
{
   public final static String INDEXABLE_DOCUMENT_KEY = "org.sixstreams.search.indexable.documents";

   // event types
   public final static String PRE_PROCESS = "PRE_PROCESS";
   public final static String PROCESSING = "PROCESSING";
   public final static String POST_PROCESS = "POST_PROCESS";
   public final static String PRE_INDEX = "PRE_INDEX";
   public final static String INDEXING = "INDEXING";
   public final static String POST_INDEX = "POST_INDEX";
   public final static String AUDITING = "AUDITING";
   public final static String ERROR = "ERROR";
   public final static String SECURE_DOCUMENT = "SECURE_DOCUMENT";
   public final static String COMPLETE = "COMPLETE";
   public final static String START = "START";

   // Life cycle of a document

   public enum Phase
   {
      CRAWL,
      RETRIEVE,
      INDEX,
      PROCESS,
      QUERY;
   }

   private String mEventType;
   private Phase mPhase;
   private transient Object mDocument;
   private HashMap<String, Object> parameters = new HashMap<String, Object>();

   /**
    * Used internally only for raising the event.
    *
    * @param type
    *            the type of the event.
    * @param phase
    *            the phase of this event.
    * @param doc
    *            host object for this event.
    */
   public LifeCycleEvent(String type, Phase phase, Object doc)
   {
      mEventType = type;
      mPhase = phase;
      mDocument = doc;
   }

   /**
    * Returns host object of this event.
    *
    * @return host object.
    */
   public Object getObject()
   {
      return mDocument;
   }

   /**
    * Returns event type.
    *
    * @return event type.
    */
   public String getEventType()
   {
      return mEventType;
   }

   /**
    * Returns the phase.
    *
    * @return phase of the event.
    */
   public Phase getPhase()
   {
      return mPhase;
   }

   // whether the status is handled

   /**
    * Returns the indicator whether an error has been handled. If not, the
    * framework will log the error message.
    *
    * @return error handling state
    */
   public boolean isErrorHandled()
   {
      return false;
   }

   public void put(String key, Object value)
   {
      parameters.put(key, value);

   }
}
