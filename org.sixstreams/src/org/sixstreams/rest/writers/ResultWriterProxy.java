package org.sixstreams.rest.writers;

import java.util.List;

public class ResultWriterProxy
        extends ResultWriter {

    private final ResultWriter resultWriter;

    public ResultWriterProxy(String format) {
        resultWriter = new JSONWriter();
    }

    @Override
    public StringBuffer toString(Object object) {
        return resultWriter.toString(object);
    }

    @Override
    public void setExcludingRules(List<String> rules) {
        resultWriter.setExcludingRules(rules);
    }

    /**
     *
     * @param rules
     */
    @Override
    public void setIncludingRules(List<String> rules) {
        resultWriter.setIncludingRules(rules);
    }

    @Override
    public String getContentType() {
        return resultWriter.getContentType();
    }
}
