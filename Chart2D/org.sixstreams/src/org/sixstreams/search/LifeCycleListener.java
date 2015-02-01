package org.sixstreams.search;

/**
 * The generic life cycle listener that used through out framework for
 * external code to be plugged into the state management of a document.
 */
public interface LifeCycleListener
{
   /**
    * Method to be invoked when a life cycle event emits
    * @param event that causes this method to be called.
    */
   public void onLifeCycleEvent(LifeCycleEvent event);
}
