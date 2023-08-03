const list = [
  "bart@moth.social",
  "jtomchak@moth.social",
  "rileyhBat@moth.social",
  "jawshoeadan@mastodon.social",
  "rocketdonut@mastodon.social",
  "jimmyd2@fosstodon.org",
  "vmstan@vmst.io",
  "matt@toot.mattedwards.org",
  "marcel@mastodon.social",
  "marcus@tut.iterate.no",
  "prvrtl@mas.to",
  "ramarope@mastodon.social",
  "matko@moth.social",
  "bnolens@moth.social",
  "robstahlnecker@mastodon.social",
  "djerbien@mastodon.social",
  "manubermu@mastodon.social",
  "luis_in_brief@social.coop",
  "nick@moth.social",
  "shli7euoiljlks@moth.social",
  "PlinyTheOlder@sfba.social",
  "romegat46@moth.social",
  "eulanov@m.eula.dev",
  "Champagne@masto.ai",
  "jairhenrique@ursal.zone",
  "biquet@mas.to",
  "andrewford@mastodon.nz",
  "mar15test@moth.social",
  "mattmarenic@balkan.fedive.rs",
  "kevinSpirit@moth.social",
  "Psylian@ohai.social",
  "nick@melb.social",
  "sfdayzie@moth.social",
  "Nenewapte@mas.to",
  "jrmajor@phpc.social",
  "zenfisher@mstdn.social",
  "teddyc@bne.social",
  "aroom@tooting.ch",
  "amarzar@mas.to",
  "deborag@techhub.social",
  "Strwpok@mastodon.world",
  "beardy_mike@4bear.com",
  "Sushi@mamot.fr",
  "lmfra@hessen.social",
  "iworx@mastodon.ninja",
  "purplelime@mastodon.social",
  "box464@mastodon.social",
  "mjf_pro@hachyderm.io",
  "matt@oslo.town",
  "josheron@mastodon.social",
  "avy@social.lol",
  "thomasrost@oslo.town",
  "chris@arcticwind.social",
  "nithou@piaille.fr",
  "ciberturtle@mastodon.social",
  "smalls@ocw.social",
  "benjamin@moth.social",
  "nesl247@mastodon.social",
  "glenne@mas.to",
  "Chrispyapple@stranger.social",
  "sbm@masto.ai",
  "maffeis@mastodon.social",
  "dokter@infosec.exchange",
  "nateb@pdx.social",
  "Zolees@toot.community",
  "pixeltracker@sigmoid.social",
  "Lyocamy@qdon.space",
  "Craktok@mas.to",
  "randmbits@mstdn.social",
  "Luigirom7@masto.es",
  "thoralf@soc.umrath.net",
  "socialuser@mas.to",
  "whisimon@mastodon.social",
  "qbls3dv7@mastodon.social",
  "aku@anakmanis.com",
  "filmfreak75@mastodon.cloud",
  "richy@mastodon.social",
  "mcul@mastodon.social",
  "jackjohnbrown@mastodon.social",
  "SENTINELITE@moth.social",
  "byakko@pcgamer.social",
  "mcul@social.lol",

  "box464@moth.social",
  "dmnelson@mastodon.social",
  "eulanov@moth.social",
  "lowskid@mastodon.social",
  "andreadraghetti@mastodon.social",
  "alien@mstdn.id",
  "ninerjoshua@social.vivaldi.net",
  "vggonz@mastodon.denibol.com",
  "byakko@fedibird.com",
];

const url = "http://localhost:3000/api/v1/foryou/users"; // Replace this with your actual API endpoint URL

// Create the HTTP request options
const requestOptions = (acct) => ({
  method: "POST",
  headers: {
    "Content-Type": "application/json",
    Authorization: "Bearer 4fcbe8ec7d1fc1cb672b2c471faab572",
  },
  body: JSON.stringify({ acct: acct }),
});

// Send the HTTP request using fetch
const httpFetch = (url, requestOptions) =>
  fetch(url, requestOptions)
    .then((response) => {
      if (!response.ok) {
        throw new Error(`HTTP error! Status: ${response.status}`);
      }
      return response.text();
    })
    .then((data) => {
      console.log(data); // Handle the response from the server if needed
    })
    .catch((error) => {
      console.error("Error:", error);
    });

list.map(async (acct) => {
  let requestOp = requestOptions(acct);
  await httpFetch(url, requestOp);
});
