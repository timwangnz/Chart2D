package org.sixstreams.social;

import org.sixstreams.rest.IdObject;

public class SocialCommon extends IdObject {
	// subject of the activity, task
	private String resourceType;
	private String resourceId;
	private String resourceTitle;
	private String resourceOwner;

	private boolean publicObject;

	public void setPublicObject(boolean publicObject) {
		this.publicObject = publicObject;
	}

	public boolean isPublicObject() {
		return publicObject;
	}

	public String getResourceType() {
		return resourceType;
	}

	public void setResourceType(String resourceType) {
		this.resourceType = resourceType;
	}

	public String getResourceId() {
		return resourceId;
	}

	public void setResourceId(String resourceId) {
		this.resourceId = resourceId;
	}

	public String getResourceTitle() {
		return resourceTitle;
	}

	public void setResourceTitle(String resourceTitle) {
		this.resourceTitle = resourceTitle;
	}

	public String getResourceOwner() {
		return resourceOwner;
	}

	public void setResourceOwner(String resourceOwner) {
		this.resourceOwner = resourceOwner;
	}
}
