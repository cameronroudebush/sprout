<p align="center">
  <img width="75%" src="https://media.githubusercontent.com/media/cameronroudebush/sprout/master/frontend/assets/logo/color-transparent.png">
  <br>
  <img href="https://hub.docker.com/r/croudebush/sprout" src="https://img.shields.io/docker/pulls/croudebush/sprout?style=for-the-badge&logo=docker" alt="Docker Pulls">
  <img href="https://github.com/cameronroudebush/sprout/releases/latest" src="https://img.shields.io/github/v/tag/cameronroudebush/sprout?label=latest%20release&style=for-the-badge&logo=github" alt="GitHub Tag">
</p>

# What is Sprout?

Sprout is a financial management app designed to give you a clear, simple view of your money. We specialize in providing a daily snapshot of your financial data by automatically tracking your accounts using financial APIs. This allows you to easily view things like account balances and stock holdings, helping you stay on top of your financial health.

Want to to see more? Check out our **[overview site!](https://sprout.croudebush.net)**

<p align="center">
  <img width="75%" src="https://media.githubusercontent.com/media/cameronroudebush/sprout/master/docs/images/store/horizontal.png" alt="Transactions Page"/>
</p>

# Getting Started

Getting started with sprout is easy! All you need is a computer running docker that you have access to. You can use the following compose:

```yml
sprout:
    container_name: sprout
    image: croudebush/sprout:stable
    volumes:
        # The database .sqlite file will be stored in /sprout
        - /appdata/sprout:/sprout
    ports:
        - 80:80
    restart: unless-stopped
    environment:
        TZ: America/New_York
        sprout_encryptionKey: ${SPROUT_ENCRYPTION_KEY}
```

After launching the container, navigate to `http://localhost` in your browser to begin the setup process.

You can review the [documentation](https://sprout.croudebush.net/getting-started) for more information on how to use sprout.

# Additional Information

[🌐 Website](https://sprout.croudebush.net/) &nbsp;&nbsp;•&nbsp;&nbsp; [📸 Screenshots](https://sprout.croudebush.net/images/mobile) &nbsp;&nbsp;•&nbsp;&nbsp; [🔒 Privacy Policy](https://sprout.croudebush.net/privacy-policy) &nbsp;&nbsp;•&nbsp;&nbsp; [📚 Documentation](https://sprout.croudebush.net/getting-started) &nbsp;&nbsp;•&nbsp;&nbsp; [⚖️ License](https://github.com/cameronroudebush/sprout/blob/master/LICENSE.md) &nbsp;&nbsp;•&nbsp;&nbsp; [🔖 Changelog](https://github.com/cameronroudebush/sprout/releases)
