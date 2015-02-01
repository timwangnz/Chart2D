package org.sixstreams.search.data.java.annotations;

import java.lang.annotation.Documented;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

@Documented
@Retention(RetentionPolicy.RUNTIME)

public @interface Searchable
{
   String title();
   
   boolean isSecure() default true; //if this field is allowed for change from default UI

   String keywords() default "";

   String plugin() default "";

   String content() default "";
}
