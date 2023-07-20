## Content Discovery with Account Relay in the Fediverse

The fediverse is an amazing platform that has seen an influx of new users, but many have found it "hard" or "difficult to use." Admittedly, the setup process can be quite challenging, but the good news is that progress has been made in addressing these pain points. We are continuously striving to create a more user-friendly experience, and one crucial aspect we're focusing on is content discovery.

**Curated Feeds - A Step in the Right Direction**

The initial efforts to enhance content discovery included creating curated feeds like 'For You,' where we manually searched for and compiled a list of interesting accounts for users to follow. This approach showed great promise as it allowed users to stumble upon exciting content and discover new accounts they might not have found otherwise. It also helped users expand and improve their own home feeds.

**The Challenge of Personalization**

While the curated 'For You' feed had its benefits, it wasn't personalized enough. Each user has unique interests, and relying solely on a generic curated list limited the potential for a truly tailored experience. To tackle this challenge, we introduced the concept of a "Personal For You" feed, specifically tailored to each user's interests.

![](https://jessetomchak.com/uploads/2023/254982152-75696f2e-a05c-4efa-9d40-449cc4b9cbe7.png)

**Introducing Account Relay**

Account Relay emerged as the solution to bring personalized content to users' feeds. The main challenge was how to include "friends of friends" accounts in a user's feed without them having to follow each of these accounts individually. We explored several options, including sending partial lists of accounts with available statuses or setting up a bot to follow all accounts from the "friends of friends" list, but these solutions were far from ideal.

**Cooperative Relays vs. Account Relay**

Cooperative relays, like the [Activity Relay Server](https://github.com/yukimochi/Activity-Relay) by Yukimochi and [FakeRelay](https://github.com/g3rv4/FakeRelay) by Gervasio Marchand, offered some sharing of statuses between instances, but they weren't enough to cater to the personalized needs of each user.

**How Account Relay Works**

Account Relay operates as a standard relay relationship with an instance, but with a twist. It retrieves the statuses from a carefully defined list of accounts for each Mammoth user and delivers those statuses directly to the inbox of Moth.social, ensuring users receive content from "friends of friends" accounts, even if they haven't followed them individually. The list of accounts is continuously updated through authenticated HTTP requests from Moth.Social, allowing the "Personal For You" feed to adapt and change with each user's interests.

![](https://jessetomchak.com/uploads/2023/accountrelay-process.png)

**The Promise of Personalized Content**

With Account Relay, we believe the "Personal For You" feed will revolutionize content discovery in the fediverse. Users can now find relevant and engaging content, specific to their interests, without the hassle of manually following numerous accounts. As we continue to refine and develop this feature, we are committed to improving the fediverse experience for all its awesome users.

In conclusion, Account Relay marks a significant step forward in creating a more personalized and enjoyable fediverse experience. By connecting users to content from accounts aligning with their interests, we hope to foster a stronger sense of community and make content discovery a seamless and delightful process for everyone. As we move forward, we eagerly anticipate the positive impact of Account Relay and are committed to pushing the boundaries of what the fediverse can achieve.
