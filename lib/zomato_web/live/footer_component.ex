defmodule ZomatoWeb.FooterComponent do
  use ZomatoWeb, :live_component

  def render(assigns) do
    ~H"""
    <footer>
      <div class="footer-data">
        <section class="footer-top">
          <img
            src="https://b.zmtcdn.com/web_assets/b40b97e677bc7b2ca77c58c61db266fe1603954218.png?fit=around|198:42&amp;crop=198:42;*,*"
            alt="Zomato logo"
            class="sc-elhb8j-1 ixsoFB"
          />
          <div class="row">
            <div class="country-dropdown">
              <img src={~p"/images/india.png"} class="flag" />
              <p>India</p>
              <i class="fa fa-chevron-down"></i>
            </div>
            <div class="country-dropdown">
              <i data-feather="globe"></i>
              <p>English</p>
              <i class="fa fa-chevron-down"></i>
            </div>
          </div>
        </section>
        <section class="middle row">
          <div class="footer-links">
            <h6 class="footer-title">About Zomato</h6>
            <ul>
              <li>Who we are</li>
              <li>Blog</li>
              <li>Work with us</li>
              <li>Investor Relations</li>
              <li>Report Fraud</li>
              <li>Contact us</li>
            </ul>
          </div>

          <div class="footer-links">
            <h6 class="footer-title">Zomaverse</h6>
            <ul>
              <li>Zomato</li>
              <li>Blinkit</li>
              <li>Feeding India</li>
              <li>Hyperpure</li>
              <li>Zomaland</li>
            </ul>
          </div>

          <div class="footer-links column">
            <div class="footer-links">
              <h6 class="footer-title">For Restaurants</h6>
              <ul>
                <li>Partner With Us</li>
                <li>Apps for you</li>
              </ul>
            </div>

            <div class="footer-links">
              <h6 class="footer-title">For Enterprises</h6>
              <ul>
                <li>Zomato For Enterprises</li>
              </ul>
            </div>
          </div>

          <div class="footer-links">
            <h6 class="footer-title">Learn more</h6>
            <ul>
              <li>Privacy</li>
              <li>Security</li>
              <li>Terms</li>
              <li>Sitemap</li>
            </ul>
          </div>

          <div class="footer-links">
            <h6 class="footer-title">Social Links</h6>
            <div class="socials">
              <ul>
                <li><i class="fa fa-linkedin"></i></li>
                <li><i class="fa fa-instagram"></i></li>
                <li><i class="fa fa-twitter"></i></li>
                <li><i class="fa fa-youtube"></i></li>
                <li><i class="fa fa-facebook"></i></li>
              </ul>
            </div>
            <div class="buttons">
              <img
                src="https://b.zmtcdn.com/data/webuikit/23e930757c3df49840c482a8638bf5c31556001144.png"
              />
              <img
                src="https://b.zmtcdn.com/data/webuikit/9f0c85a5e33adb783fa0aef667075f9e1556003622.png"
              />
            </div>
          </div>
        </section>

        <hr />
        <section class="end">
          By continuing past this page, you agree to our Terms of Service,
          Cookie Policy, Privacy Policy and Content Policies. All trademarks are
          properties of their respective owners. 2008-2023 © Zomato™ Ltd. All
          rights reserved.
        </section>
        <section class="end">Made by: Jayesh Sadhwani</section>
      </div>
    </footer>

    """
  end

end
