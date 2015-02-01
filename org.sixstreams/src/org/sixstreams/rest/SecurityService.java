package org.sixstreams.rest;

import com.google.gson.Gson;

import java.io.IOException;

import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.io.IOUtils;

import org.sixstreams.Constants;
import org.sixstreams.mailer.Mailer;
import org.sixstreams.search.IndexingException;
import org.sixstreams.search.SearchContext;
import org.sixstreams.search.SearchException;
import org.sixstreams.search.data.PersistenceManager;
import org.sixstreams.search.meta.MetaDataManager;
import org.sixstreams.search.meta.SearchableObject;
import org.sixstreams.search.util.ClassUtil;
import org.sixstreams.search.util.ContextFactory;
import org.sixstreams.social.Person;
import org.sixstreams.social.User;

import sun.misc.BASE64Decoder;


/**
 * Authentication is done be checking the Authentication field in the request
 * header. It should be in following form Basic:
 * Base64Encoded(username/password)
 *
 * The server will look for user per username from database, if found,
 * org.sixstreams.social.Person, its password is obtained from the object.
 * However, this password is not password, but username/password encrypted with
 * itself as the key. This way, only the user knows the key. Then it is Base64
 * encoded so we can store it as a string.
 *
 * The income credential will be preocess the same way and compared with stored
 * value.
 *
 * If header specifies X-sixstrearms-security-request with value signup, then
 * the execution path will be directed to signup flow.
 *
 * Return true means the request is ok for further execution. Return false means
 * we have handled everything and return to the caller right way.
 *
 * All other possible branch will result in an exception.
 *
 * @author anpwang
 *
 */
public class SecurityService extends DefaultService
{
	static boolean securityDisabled = "TRUE".equalsIgnoreCase(MetaDataManager.getProperty(MetaDataManager.SECURITY_FLAG));

	static SecurityService authenticator = new SecurityService();

	public static SecurityService getService()
	{
		return authenticator;
	}

	public static String userClass = User.class.getName();
	public static String profileClass = MetaDataManager.getProperty("org.sixstreams.security.userClass");

	@SuppressWarnings("unchecked")
	public static Class<? extends Person> getProfileClass()
	{
		return (Class<? extends Person>) ClassUtil.getClass(profileClass);
	}

	private Person getProfile(String username)
	{
		if (username == null || username.contains("*") || username.contains("?") || username.contains(":") || username.length() == 0)
		{
			return null;
		}

		Person cachedPerson = (Person) GoodCache.getCache(profileClass).get(username);
		if (cachedPerson != null)
		{
			return cachedPerson;
		}
		PersistenceManager pm = new PersistenceManager();
		Map<String, Object> filters = new HashMap<String, Object>();
		filters.put(Constants.USERNAME, username);
		try
		{
			@SuppressWarnings("unchecked")
			Class<? extends Person> clazz = (Class<? extends Person>) ClassUtil.getClass(profileClass);
			if (clazz == null)
			{
				sLogger.warning("Failed to login user " + username + ", can not load person class " + profileClass);
				return null;
			}
			List<? extends Person> objects = pm.query(filters, clazz, 0, 10);
			if (objects != null && objects.size() > 0)
			{
				if (objects.size() > 1)
				{
					sLogger.warning("Found more than one user with the same user name, should not hannen, " + username + " of " + profileClass);
				}
				Person person = (Person) objects.get(0);
				GoodCache.getCache(profileClass).put(username, person);
				return person;
			}
			else
			{
				sLogger.warning("Failed to login user - not found " + username + " as " + profileClass);
				return null;
			}
		}
		catch (SearchException e)
		{
			// sLogger.warning("Failed to login user " + username + " as " +
			// userClass + " - " + e);
			return null;
		}
	}

	private User getUserByUsername(String username, String authSource)
	{
		if (username == null || username.contains("*") || username.contains("?") || username.length() == 0)
		{
			return null;
		}

		if (authSource == null || authSource.isEmpty())
		{
			authSource = "sixstreams.com";
		}

		User cachedPerson = (User) GoodCache.getCache(userClass).get(username);

		if (cachedPerson != null)
		{
			return cachedPerson;
		}
		PersistenceManager pm = new PersistenceManager();
		Map<String, Object> filters = new HashMap<String, Object>();

		filters.put(Constants.USERNAME, username);
		filters.put(Constants.AUTH_SOURCE, authSource);
		try
		{
			@SuppressWarnings("unchecked")
			Class<User> clazz = (Class<User>) ClassUtil.getClass(userClass);
			if (clazz == null)
			{
				sLogger.warning("Failed to login user " + username + ", can not load user ");
				return null;
			}
			List<? extends User> objects = pm.query(filters, clazz, 0, 10);
			if (objects != null && objects.size() > 0)
			{
				User user = (User) objects.get(0);
				return user;
			}
			else
			{
				sLogger.warning("Failed to find user " + username);
				return null;
			}
		}
		catch (SearchException e)
		{
			// sLogger.warning("Failed to login user " + username + " as " +
			// userClass + " - " + e);
			return null;
		}
	}

	public void delete(User user) throws RestfulException
	{
		PersistenceManager pm = new PersistenceManager();
		try
		{
			// remove from cache
			GoodCache.getCache(userClass).delete(user);
			GoodCache.getCache(profileClass).delete(user.getProfile());
			// remove from db
			pm.delete(user.getProfile());
			pm.delete(user);
			sLogger.warning("Account has been removed " + user);
		}
		catch (IndexingException e)
		{
			throw new RestfulException(500, "Failed to remove account", Constants.ACTION_SECURITY);
		}
	}

	public User createUser(HttpServletRequest request, String authSource) throws RestfulException
	{
		String contentType = request.getContentType();
		if (contentType.contains(Constants.CONTENT_TYPE_JSON))
		{
			String json = null;
			try
			{
				json = IOUtils.toString(request.getInputStream());
			}
			catch (IOException e1)
			{
				sLogger.log(Level.SEVERE, "Failed to understande the income request", e1);
				throw new RestfulException(400, "Failed to understande the income request", Constants.ACTION_SECURITY);
			}

			SearchableObject object = MetaDataManager.getSearchableObject(userClass);
			if (object != null)
			{
				Gson gson = new Gson();
				User obj = (User) gson.fromJson(json, ClassUtil.getClass(userClass));

				if (!(obj instanceof User))
				{
					throw new RestfulException(401, "User class must be sub class of " + userClass, Constants.ACTION_SECURITY);
				}
				assertPerson((User) obj);
				String username = ((User) obj).getUsername();
				User person = this.getUserByUsername(username, authSource);

				if (person != null)
				{
					if (authSource.equals("facebook.com"))
					{
						return person;
					}
					else
					{
						throw new RestfulException(406, "Username has been taken, please select a different username", Constants.ACTION_SECURITY);
					}
				}

				obj.setCreatedBy(obj.getId());
				obj.setDateCreated(new Date());
				PersistenceManager pm = new PersistenceManager();
				try
				{
					pm.insert(obj);
					Person profile = (Person) gson.fromJson(json, ClassUtil.getClass(profileClass));
					// every one gets 10 points
					profile.setPoints(10);
					profile.setCreatedBy(profile.getId());
					profile.setCreatedByName(profile.getFirstName() + " " + profile.getLastName() + "---" + profile.getId());
					profile.setDateCreated(new Date());
					pm.insert(profile);

					obj.setProfile(profile);
					try
					{
						Mailer mailer = Mailer.getInstance();
                              
						mailer.sendMail(profile.getEmail(), null, "Welcome to SixStreams", "Hi, " + profile.getFirstName() + " " + profile.getLastName()
										+ "\nThanks for chosing SixStreams, please click the link below to finish you registration process. \nTim");
					}
					catch (IOException e)
					{
						// TODO Auto-generated catch block
						e.printStackTrace();
					}
					sLogger.info("An user and profile has been created " + profile);
				}
				catch (IndexingException e)
				{
					throw new RestfulException(500, "Failed to create user", Constants.ACTION_SECURITY);
				}

				return (User) obj;
			}
			else
			{
				throw new RestfulException(401, "Object definition not found " + userClass, Constants.ACTION_SECURITY);
			}
		}
		else
		{
			throw new RestfulException(400, "Content type not supported " + contentType, Constants.ACTION_SECURITY);
		}
	}

	// returns true if
	public boolean performService(HttpServletRequest request, HttpServletResponse response)
	{
		parseRequest(request, response);
		SearchContext ctx = ContextFactory.getSearchContext();
		// security request status
		boolean noSecurity = securityDisabled || (!ctx.getSearchableObject().isSecure() && request.getMethod().equals("GET"));
		if (!noSecurity)
		{
			if (ctx.getAppId() == null || ctx.getAppKey() == null)
			{
				throw new RestfulException(401, "Access denied, a request must be made with valid application id/key pair", Constants.ACTION_SECURITY);
			}
		}

		String securityRequest = request.getHeader(Constants.SECURITY_REQUEST);
		String authSource = request.getHeader(Constants.SECURITY_REQUEST_SOURCE_KEY);
		if (securityRequest != null && securityRequest.equals(Constants.SIGN_UP))
		{
			try
			{
				User person = createUser(request, authSource);
				response.getWriter().write(writer.toString(person).toString());
			}
			catch (RestfulException re)
			{
				throw re;
			}
			catch (Exception e)
			{
				sLogger.log(Level.SEVERE, "Failed to create the user", e);
				throw new RestfulException(401, "Failed to create the user", Constants.ACTION_SECURITY);
			}
			return false;
		}

		String authenticationInfo = request.getHeader(Constants.AUTHENTICATION);
		if (authenticationInfo != null)
		{
			String[] elements = authenticationInfo.split(" ");

			if (elements.length == 2 && "Basic".equals(elements[0]))
			{
				BASE64Decoder decoder = new BASE64Decoder();
				byte[] decodedBytes;
				try
				{
					decodedBytes = decoder.decodeBuffer(elements[1]);
				}
				catch (IOException e1)
				{
					throw new RestfulException(400, "Invalid request", Constants.ACTION_SECURITY);
				}

				String credential = new String(decodedBytes);

				elements = credential.split(":");
				if (elements.length == 2)
				{
					User user = this.getUserByUsername(elements[0], authSource);
					if (user == null)
					{
						if (noSecurity && !Constants.SIGN_IN.equals(securityRequest))
						{
							return true;
						}
						else
						{
							throw new RestfulException(401, "Failed to signin the user", Constants.ACTION_SECURITY);
						}
					}

					ctx.setUserName(elements[0]);
					// password stored in db base64 encoded sym
					// encrypted with password itself
					// username/password format

					String password = user.getPassword();
					if (password.equals(elements[1]))
					{
						Person profile = getProfile(user.getUsername());
						if (securityRequest != null && securityRequest.equals(Constants.SIGN_IN))
						{
							try
							{
								user.setProfile(profile);
								String profileJsonString = writer.toString(profile).toString();
								String userJsonString = writer.toString(user).toString();
								System.err.println(userJsonString);
								System.err.println(profileJsonString);
								response.getWriter().write(userJsonString);
							}
							catch (IOException e)
							{
								throw new RestfulException(500, "Failed to serialized an object", Constants.ACTION_SECURITY);
							}
							return false;
						}

						GoodCache.getCache(userClass).put(user.getUsername(), user);
						user.setProfile(profile);
						ctx.setUser(profile);

						String method = request.getMethod();
						if (method.equals("DELETE") && securityRequest != null && securityRequest.equals(Constants.DELETE_ACCOUNT))
						{
							delete(user);
							return false;
						}
						return true;
					}
					else
					{
						if (noSecurity)
						{
							sLogger.severe("Security has been turned off, for testing only");
							return true;
						}
						else
						{
							throw new RestfulException(401, "username or password does not match", Constants.ACTION_SECURITY);
						}
					}
				}
				else
				{
					if (noSecurity)
					{
						return true;
					}
					else
					{
						throw new RestfulException(401, "Not enough information in basic authentication - username/password", Constants.ACTION_SECURITY);
					}
				}
			}
		}
		else
		{
			if (noSecurity)
			{
				return true;
			}
			else
			{
				throw new RestfulException(401, "Unsupported security request", Constants.ACTION_SECURITY);// bad
				// request
			}
		}

		return false;
	}

	private void assertPerson(User user) throws RestfulException
	{
		String username = user.getUsername();
		String email = user.getEmail();
		String password = user.getPassword();
		if (username == null || username.trim().length() == 0)
		{
			throw new RestfulException(400, "Username is required", Constants.ACTION_SECURITY);
		}

		if (email == null || email.trim().length() == 0)
		{
			throw new RestfulException(400, "Email is required", Constants.ACTION_SECURITY);
		}

		if (password == null || password.trim().length() == 0)
		{
			throw new RestfulException(400, "Password is required", Constants.ACTION_SECURITY);
		}
		// TODO more rules
		if (username.contains("*") || username.contains("?") || username.contains(":"))
		{
			throw new RestfulException(400, "Username must not contain special charactors", Constants.ACTION_SECURITY);
		}
	}
}
