defmodule ZomatoWeb.LiveComponents.Useless do
  use ZomatoWeb, :live_component

  def render(assigns) do
    ~H"""
    <div>
    <section class="explore-options">
        <div class="heading">Explore options near me</div>
        <div class="accordions">
          <div class="accordion">
            <div class="accordion-container">
              <div class="accordion-title">Popular cuisines near me</div>
              <i class="fa fa-chevron-down fa-2x"></i>
            </div>
            <div class="accordion-data">
              <ul>
                <li>Bakery food near me</li>
                <span class="small-circle"></span>
                <li>Beverages food near me</li>
                <span class="small-circle"></span>
                <li>Biryani food near me</li>
                <span class="small-circle"></span>
                <li>Burger food near me</li>
                <span class="small-circle"></span>
                <li>Chinese food near me</li>
                <span class="small-circle"></span>
                <li>Continental food near me</li>
                <span class="small-circle"></span>
                <li>Desserts food near me</li>
                <span class="small-circle"></span>
                <li>Italian food near me</li>
                <span class="small-circle"></span>
                <li>Kebab food near me</li>
                <span class="small-circle"></span>
                <li>Mithai food near me</li>
                <span class="small-circle"></span>
                <li>Momos food near me</li>
                <span class="small-circle"></span>
                <li>Mughlai food near me</li>
                <span class="small-circle"></span>
                <li>North Indian food near me</li>
                <span class="small-circle"></span>
                <li>Pasta food near me</li>
                <span class="small-circle"></span>
                <li>Pizza food near me</li>
                <span class="small-circle"></span>
                <li>Rolls food near me</li>
                <span class="small-circle"></span>
                <li>Sandwich food near me</li>
                <span class="small-circle"></span>
                <li>Shake food near me</li>
                <span class="small-circle"></span>
                <li>South Indian food near me</li>
                <span class="small-circle"></span>
                <li>Street food near me</li>
              </ul>
            </div>
          </div>

          <div class="accordion">
            <div class="accordion-container">
              <div class="accordion-title">
                Popular restaurant types near me
              </div>
              <i class="fa fa-chevron-down fa-2x"></i>
            </div>
            <div class="accordion-data">
              <ul>
                <li>Bakery food near me</li>
                <span class="small-circle"></span>
                <li>Beverages food near me</li>
                <span class="small-circle"></span>
                <li>Biryani food near me</li>
                <span class="small-circle"></span>
                <li>Burger food near me</li>
                <span class="small-circle"></span>
                <li>Chinese food near me</li>
                <span class="small-circle"></span>
                <li>Continental food near me</li>
                <span class="small-circle"></span>
                <li>Desserts food near me</li>
                <span class="small-circle"></span>
                <li>Italian food near me</li>
                <span class="small-circle"></span>
                <li>Kebab food near me</li>
                <span class="small-circle"></span>
                <li>Mithai food near me</li>
                <span class="small-circle"></span>
                <li>Momos food near me</li>
                <span class="small-circle"></span>
                <li>Mughlai food near me</li>
                <span class="small-circle"></span>
                <li>North Indian food near me</li>
                <span class="small-circle"></span>
                <li>Pasta food near me</li>
                <span class="small-circle"></span>
                <li>Pizza food near me</li>
                <span class="small-circle"></span>
                <li>Rolls food near me</li>
                <span class="small-circle"></span>
                <li>Sandwich food near me</li>
                <span class="small-circle"></span>
                <li>Shake food near me</li>
                <span class="small-circle"></span>
                <li>South Indian food near me</li>
                <span class="small-circle"></span>
                <li>Street food near me</li>
              </ul>
            </div>
          </div>


        </div>
    </section>
     <div class="accordion">
            <div class="accordion-container">
              <div class="accordion-title">Top restraunt chains</div>
              <i class="fa fa-chevron-down fa-2x"></i>
            </div>
            <div class="accordion-data">
              <ul>
                <li>Bakery food near me</li>
                <span class="small-circle"></span>
                <li>Beverages food near me</li>
                <span class="small-circle"></span>
                <li>Biryani food near me</li>
                <span class="small-circle"></span>
                <li>Burger food near me</li>
                <span class="small-circle"></span>
                <li>Chinese food near me</li>
                <span class="small-circle"></span>
                <li>Continental food near me</li>
                <span class="small-circle"></span>
                <li>Desserts food near me</li>
                <span class="small-circle"></span>
                <li>Italian food near me</li>
                <span class="small-circle"></span>
                <li>Kebab food near me</li>
                <span class="small-circle"></span>
                <li>Mithai food near me</li>
                <span class="small-circle"></span>
                <li>Momos food near me</li>
                <span class="small-circle"></span>
                <li>Mughlai food near me</li>
                <span class="small-circle"></span>
                <li>North Indian food near me</li>
                <span class="small-circle"></span>
                <li>Pasta food near me</li>
                <span class="small-circle"></span>
                <li>Pizza food near me</li>
                <span class="small-circle"></span>
                <li>Rolls food near me</li>
                <span class="small-circle"></span>
                <li>Sandwich food near me</li>
                <span class="small-circle"></span>
                <li>Shake food near me</li>
                <span class="small-circle"></span>
                <li>South Indian food near me</li>
                <span class="small-circle"></span>
                <li>Street food near me</li>
              </ul>
            </div>
          </div>

          <div class="accordion">
            <div class="accordion-container">
              <div class="accordion-title">Cities we deliver to</div>
              <i class="fa fa-chevron-down fa-2x"></i>
            </div>
            <div class="accordion-data">
              <ul>
                <li>Bakery food near me</li>
                <span class="small-circle"></span>
                <li>Beverages food near me</li>
                <span class="small-circle"></span>
                <li>Biryani food near me</li>
                <span class="small-circle"></span>
                <li>Burger food near me</li>
                <span class="small-circle"></span>
                <li>Chinese food near me</li>
                <span class="small-circle"></span>
                <li>Continental food near me</li>
                <span class="small-circle"></span>
                <li>Desserts food near me</li>
                <span class="small-circle"></span>
                <li>Italian food near me</li>
                <span class="small-circle"></span>
                <li>Kebab food near me</li>
                <span class="small-circle"></span>
                <li>Mithai food near me</li>
                <span class="small-circle"></span>
                <li>Momos food near me</li>
                <span class="small-circle"></span>
                <li>Mughlai food near me</li>
                <span class="small-circle"></span>
                <li>North Indian food near me</li>
                <span class="small-circle"></span>
                <li>Pasta food near me</li>
                <span class="small-circle"></span>
                <li>Pizza food near me</li>
                <span class="small-circle"></span>
                <li>Rolls food near me</li>
                <span class="small-circle"></span>
                <li>Sandwich food near me</li>
                <span class="small-circle"></span>
                <li>Shake food near me</li>
                <span class="small-circle"></span>
                <li>South Indian food near me</li>
                <span class="small-circle"></span>
                <li>Street food near me</li>
              </ul>
            </div>
    </div>
    </div>
    """
  end

end
