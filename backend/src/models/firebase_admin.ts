import { initializeApp } from "firebase-admin/app";
import { credential, app, ServiceAccount } from "firebase-admin";

class FirebaseAdmin {
    private static instance: FirebaseAdmin;

    /**
     * Initialize firebase database
     */
    private constructor() {
        const serviceAcount: ServiceAccount = {
            // type: "service_account",
            projectId: "posto-e4bc1",
            // private_key_id: "a1809ef118ec422bee369461cccdfb99085e9b6a",
            privateKey: "-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQCRbQ/rTJ15fxgU\nDdwMIlQh/SgnlErVZTaxMj7x9kAV2fCGjTFvs1IQm0A69t6fuV2SXn4rdJ/mqH4g\nb3U+lDFZfLQgUxMH/PKry7bU7SLSLCWME+0ze6/Vl2vo6OOtyTlq98GNK2yGqj+m\n9JSLmIrYSe/OrA3h6Y3dRzi5rUniUpo1Exk2WSLHoorAUfujQKpWiXT0Zsw50/ZV\nHvNJDFkd7udO8RchE4VNOLKiXzPM0sgpLgqx3JawJ8NtFBHlb0x6Gq0xG8mH367/\nKdifqm7YFlQKTbj4RpuVNpvzsMPeMWTE8YoHNYjtvQajg81RAUPgumdOXc1OIyOJ\ni81QDVqXAgMBAAECggEABNxrnrs9YSiln+VpRjiPQBh03F5l9In37GaF6669B8ur\ng3ve4GFS4yLJ8sV6dI8MuOBuJV9IiU6bzdNSzL8Op4W/YHxfimi+VLLCc/t087o/\n5sNqUtyVw/4xiW0pKyHhtmH9SVcWUYUuC6WyRkrYr4//aicMSuPQCVz8KlpsTCyy\neGfzK9hvh3YAQ9dG/95leqQHx7uWtecR/fWhrYRhVBgWHBnPHmN042DK8pKxWuLN\n6leX2bI6o9eUG7+PkjKI3iL4pdaIC/9S9T6PIhHTG1/6ZeGG4E5VvJZPBSS9woXL\ni7E06NPg2FHHL1bttiGvlVbBgKjD7FXSt2xrYzX4YQKBgQDKgFMrY48xonYHz0ZP\ny7O2Y3OxXduxbdY77BcQEd2X5qQ+wFA34deCCA32hmSj0hi87a306i1Gnbf25jwD\nwPOnn9+EBOsUkqdFkZmR0ULwgmWTYgVPsFRL36h5ivcdDMq1i/Fcc7QzjDNtj77t\nA/uy6zMlr+or23JxC32qfsPlYQKBgQC32Jfx/M3wMGOTmJO9o0jIUqJbTQc+DExn\nhwywFp0MKx1cBD3QuY/i60nMYqNVlwak66RKFUVhiu+vBeB0+YqAsGnuJ7ypNcR/\n5iMCbX+SOlGDOuscFKlpDVIUneQs19BNRRU+KHXpPJp9/lhhu9WYSPgNwmnYsdU+\nWIbs3N1K9wKBgC/grUlZ7bY3ih6IlEAzklbyJp1t6o6FwJxEUqObBcBvaK/pek3s\nGK8Gxn5eAhd1iiHJNFLutyu2CJPYlaHxkeo083zcSNSBZAkfxqZiSqhgvDFfgI/5\nycRyqfuqrohwyNCpuLQ6KwXxBQvHa8XQJkeEMoCbmgsqhGFT7S9Nb3WhAoGABTwL\nh35VNsOJ8kfj3QBrMBj6OnNFA4VCH6h+ufzK1+/aVCZixDCkYiek4Ebms6crL0Lu\nWJWmdhKIpIkcTPhV8zgSrA9BlefMAoBA+u63NSin7X6d9xy3fiA8+A1O0+AJNEoF\nQtHQGaX6GCBHz/CTMlTRi0K/1MWrdqz6mn/nZR0CgYA/fYzduMg86OHDCwMz/CLY\neAjycq0NNucqj5up9HO8wkwd7cLpAehp605I2nQ86mnnXUzN6f6SUmMOJInPJqcF\nZSOWOHmptYAb2NMg2ICJfzso4vFmL9FdQxouMBvT9zKJLz32AkD/PnA5sEGEeGDX\nih/Lje5OiohRUQWhzxbbdA==\n-----END PRIVATE KEY-----\n",
            clientEmail: "firebase-adminsdk-j5uw2@posto-e4bc1.iam.gserviceaccount.com",
            // client_id: "108199709701413519791",
            // auth_uri: "https://accounts.google.com/o/oauth2/auth",
            // token_uri: "https://oauth2.googleapis.com/token",
            // auth_provider_x509_cert_url: "https://www.googleapis.com/oauth2/v1/certs",
            // client_x509_cert_url: "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-j5uw2%40posto-e4bc1.iam.gserviceaccount.com",
            // universe_domain: "googleapis.com"
        }

        initializeApp({
            credential: credential.cert(serviceAcount)
        });
    }

    /**
     * Get the single instance of Firebase
     * @returns {Firebase} - the single instance of the Firebase
     */
    public static initialize(): void {
        if (!this.instance) {
            FirebaseAdmin.instance = new FirebaseAdmin();
        }
    }
}

export default FirebaseAdmin;
