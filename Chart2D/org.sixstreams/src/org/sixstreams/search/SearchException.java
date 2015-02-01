package org.sixstreams.search;

import org.sixstreams.search.res.DefaultBundle;


/**
 * Exception thrown for all search related
 * exception. This exception is thrown for general search exceptions.
 */
public class SearchException
   extends Exception
{
   private static final long serialVersionUID = 1L;

   public String getErrorCode()
   {
      return mErrorCode;
   }
   //setter for error code

   /**
    * @param errorCode
    */
   public void setErrorCode(String errorCode)
   {
      mErrorCode = errorCode;
   }

   /**
    * @inheritDoc Exception
    */
   public SearchException(String msg)
   {
      super(msg);
   }

   /**
    * @inheritDoc Exception
    */
   public SearchException(Throwable throwable)
   {
      super(throwable);
   }

   /**
    * @inheritDoc Exception
    */
   public SearchException(String message, Throwable throwable)
   {
      super(message, throwable);
   }

   /**
    * Constructs an exception from an exception, an error code and
    * an array of parameters values
    *
    * @param throwable the causing exception.
    **/
   public SearchException(String errorCode, String[] params, Throwable throwable)
   {
      super(errorCode, throwable);
      mErrorCode = errorCode;
      mParams = params;
   }

   /**
    * @inheritDoc Exception
    */
   public String getLocalizedMessage()
   {
      if (mErrorCode == null)
      {
         return super.getLocalizedMessage();
      }
      else
      {
         return DefaultBundle.getResource(mErrorCode, mParams);
      }
   }

   /*
    * accessors for parameters
    */

   /**
    * Assign parameters for the message. Parameters are to constuct
    *  error message using a template named by error code.
    * @param params array of string values.
    */
   public void setParameters(String[] params)
   {
      mParams = params;
   }

   /**
    * Retruns parameters for th eerror message.
    * @return parameters.
    */
   public String[] getParameters()
   {
      return mParams;
   }
   /* ------------------- Private member ------------------------ */
   // error code for resource bundle
   private String mErrorCode;
   //parameter values in
   //for the error message in the resource bundle.
   private String[] mParams;
}
