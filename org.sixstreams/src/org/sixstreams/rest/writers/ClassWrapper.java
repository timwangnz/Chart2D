package org.sixstreams.rest.writers;

import java.io.Serializable;

import java.lang.reflect.Field;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ClassWrapper implements Serializable {

    private static final long serialVersionUID = 1326969013260072001L;

    public ClassWrapper(Class<?> clazz) {
        name = clazz.getName();
        while (!clazz.equals(Object.class)) {
            for (Field field : clazz.getDeclaredFields()) {
                // should not add here is it is transient
                attributes.add(new FieldWrapper(field));
            }
            clazz = clazz.getSuperclass();
        }
    }

    private String name;
    private List<FieldWrapper> attributes = new ArrayList<FieldWrapper>();
    private Map<String, List<FieldWrapper>> fields = new HashMap<String, List<FieldWrapper>>();

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public Map<String, List<FieldWrapper>> getFields() {
        return fields;
    }

    public void setFields(Map<String, List<FieldWrapper>> fields) {
        this.fields = fields;
    }
}
