package org.sixstreams.rest.storage;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

import org.apache.commons.io.IOUtils;
import org.sixstreams.rest.RestBaseResource;
import org.sixstreams.rest.StorageService;
import org.sixstreams.search.meta.MetaDataManager;

public class FileStorageService implements StorageService {

    private static String baseDirectory = MetaDataManager.getProperty("org.sixstreams.search.filestorage.location");

    static {
        if (baseDirectory == null) {
            baseDirectory = System.getProperty("user.home");
        }
    }

    @Override
    public int read(OutputStream outputStream, String resourceId, RestBaseResource owner) {
        String fileDirectory = baseDirectory + File.separator + resourceId;
        try {
            return IOUtils.copy(new FileInputStream(fileDirectory), outputStream);
        } catch (FileNotFoundException e) {
            return 0;
        } catch (IOException e) {
            throw new RuntimeException("Failed to read content from " + fileDirectory, e);
        }
    }

    @Override
    public void save(InputStream inputStream, String resourceId, String contentType, RestBaseResource owner) {
        String fileDirectory = baseDirectory;
        File file = new File(fileDirectory);
        boolean good = true;
        if (!file.exists()) {
            good = file.mkdirs();
        }

        if (!good) {
            throw new RuntimeException("Failed to create directory needed for content at " + baseDirectory);
        }

        File newFile = new File(fileDirectory + File.separator + resourceId);

        if (newFile.exists()) {
			//TODO add a new version
            //throw new RuntimeException("Failed to create directory needed for content at " + baseDirectory);
        }
        try {
            IOUtils.copy(inputStream, new FileOutputStream(newFile));
        } catch (FileNotFoundException e) {
            throw new RuntimeException("Write content to " + fileDirectory, e);
        } catch (IOException e) {
            throw new RuntimeException("Write content to " + fileDirectory);
        }
    }

    @Override
    public boolean delete(RestBaseResource owner) {
        String fileDirectory = baseDirectory + File.separator + owner.getParentId();
        File newFile = new File(fileDirectory + File.separator + owner.getId());
        if (newFile.exists()) {
            return newFile.delete();
        }
        return true;//since it does not exist, report it as deleted

    }

}
