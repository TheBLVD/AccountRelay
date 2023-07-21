## Content Discovery with Account Relay in the Fediverse

PERSONALIZED FOR YOU IS NOW IN BETA. CLICK HERE TO JOIN THE WAITLIST.

The fediverse is an amazing platform that has seen an influx of new users, but many have found it "hard" or "difficult to use." Admittedly, the setup process can be quite challenging, but the good news is that progress has been made in addressing these pain points. We are continuously striving to create a more user-friendly experience, and one crucial aspect we're focusing on is content discovery.

Our first major push on improving content discovery was the introduction of the 'For You' feed, based on a curated list of interesting Mastodon accounts. This approach allows users to stumble upon exciting content and discover new accounts they might not have found otherwise. It also helped users expand and improve their own home feeds.

Next, we wanted to offer a more personalized For You experience. Each user has unique interests, and relying solely on a single curated list limits the potential for a truly tailored experience. To tackle this challenge, we are now introducing our first personalized For You feed, specifically tailored to each user's interests. Think of our new personalized For You feed as a Friend Of Friend feed: these are the posts gaining traction among the people followed by the people you already follow.

![](https://jessetomchak.com/uploads/2023/254982152-75696f2e-a05c-4efa-9d40-449cc4b9cbe7.png)

Account Relay emerged as the solution to bring personalized content to users' feeds. The main challenge was how to include "friends of friends" accounts in a user's feed without them having to follow each of these accounts individually. We explored several options, including sending partial lists of accounts with available statuses or setting up a bot to follow all accounts from the "friends of friends" list, but these solutions were far from ideal.

Cooperative relays, like the [Activity Relay Server](https://github.com/yukimochi/Activity-Relay) by Yukimochi and [FakeRelay](https://github.com/g3rv4/FakeRelay) by Gervasio Marchand, offered some sharing of statuses between instances, but they weren't enough to cater to the personalized needs of each user.

**How Account Relay Works**

Account Relay operates as a standard relay relationship with an instance, but with a twist. It retrieves the statuses from a carefully defined list of accounts for each Mammoth user and delivers those statuses directly to the inbox of Moth.social, ensuring users receive content from "friends of friends" accounts, even if they haven't followed them individually. The list of accounts is continuously updated through authenticated HTTP requests from Moth.Social, allowing the "Personal For You" feed to adapt and change with each user's interests.

![](https://jessetomchak.com/uploads/2023/accountrelay-process.png)

**Privacy and Data**

We take concerns about privacy and tracking seriously. Additionally, we believe the current set of tooling and ecosystem is unwelcoming and discouraging to new users in the fediverse communities. For Mammoth users, with a public social graph, we run a social graph search for the public following of the user's followers. What is persisted is the Mammoth's username and the generated list of usernames, not full account profiles or other connections. This data is used on the Account Relay service to send new statuses to Moth.Social. Account Relay holds the most recent status id fetched for each account and uses it to ask for only new statuses.

**The Promise of Personalized Content**

With Account Relay, we believe this personalized For You feed is a great first steps towards dramatically improved content discovery in the fediverse. Users can now find relevant and engaging content, specific to their interests, for accounts and content they may not otherwise see or know about. As we continue to refine and develop this feature, we are committed to improving the fediverse experience for everyone.

In conclusion, Account Relay marks a significant step forward in creating a more personalized and enjoyable fediverse experience. By connecting users to content from accounts aligned with their interests, we hope to foster a stronger sense of community and make content discovery a seamless and delightful process for everyone. As we move forward, we eagerly anticipate the positive impact of Account Relay and are committed to pushing the boundaries of what the fediverse can achieve.
