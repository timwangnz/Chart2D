package com.iswim.loader;

import java.util.List;

public interface LineProcessor {

    public List<Record> processLine(String standard, String line);
}
