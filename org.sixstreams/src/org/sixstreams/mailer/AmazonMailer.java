package org.sixstreams.mailer;

import java.io.IOException;

import org.sixstreams.search.meta.MetaDataManager;

import com.amazonaws.auth.PropertiesCredentials;
import com.amazonaws.services.simpleemail.AmazonSimpleEmailServiceClient;
import com.amazonaws.services.simpleemail.model.Body;
import com.amazonaws.services.simpleemail.model.Content;
import com.amazonaws.services.simpleemail.model.Destination;
import com.amazonaws.services.simpleemail.model.Message;
import com.amazonaws.services.simpleemail.model.SendEmailRequest;

public class AmazonMailer
{
	static final String FROM = MetaDataManager.getProperty("org.sixstreams.mailer.from");
	private static PropertiesCredentials credentials;
	static
	{
		try
		{
			credentials = new PropertiesCredentials(Thread.currentThread().getContextClassLoader().getResourceAsStream("AwsCredentials.properties"));
		}
		catch (Exception e)
		{
			e.printStackTrace();
		}
	}
	
	public void sendMail(String to, String cc, String subject, String body) throws IOException
	{

		Destination destination = new Destination().withToAddresses(new String[]
		{
			to
		});

		// Create the subject and body of the message.
		Content subjectContent = new Content().withData(subject);
		Content textBody = new Content().withData(body);
		Body bodyContent = new Body().withText(textBody);

		// Create a message with the specified subject and body.
		Message message = new Message().withSubject(subjectContent).withBody(bodyContent);

		// Assemble the email.
		SendEmailRequest request = new SendEmailRequest().withSource(FROM).withDestination(destination).withMessage(message);
		try
		{
			AmazonSimpleEmailServiceClient client = new AmazonSimpleEmailServiceClient(credentials);
			client.sendEmail(request);
		}
		catch (Exception ex)
		{
			ex.printStackTrace();
		}
	}

}
