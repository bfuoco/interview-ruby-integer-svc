class App extends React.Component {  
  constructor(props) {
    super();

    this.state = {
      pageId: props.pageId,
      username: props.username,
      name: props.name,
      integerValue: props.integerValue
    }
  }

  /*  loads the application, ie: renders the root component.

      if a user id and access token are present in local storage, then the application will attempt
      to obtain user information and render the status page. if any error occurs, it will fall back
      to the landing page, where the user can select to either register or login.
  */
  static Load = async() => {
    const userId = localStorage.getItem("userId");
    const accessToken = localStorage.getItem("accessToken");

    if (!userId || !accessToken) {
      ReactDOM.render(<App pageId="landing-page" />, document.getElementById("app"));

      localStorage.removeItem("userId");
      localStorage.removeItem("accessToken");
      return;
    }
    
    const response = await fetch(`${Config.API_HOST}/current/${userId}`, {
      method: "GET",
      cache: "no-cache",
      credentials: "same-origin",
      headers: {
        "Authorization": `Bearer: ${accessToken}`,
        "Content-Type": "application/vnd.api+json",
        "Accept": "application/vnd.api+json"
      }
    });
    
    const data = (await response.json()).data;
    
    if (response.ok) {
      ReactDOM.render(<App
          pageId="status-page"
          username={data.attributes.username}
          name={data.attributes.name}
          integerValue={data.attributes.integer_value} />,
        document.getElementById("app"));
    } else {
      // don't try to login again next time if we can't with these credentials
      //
      localStorage.removeItem("userId");
      localStorage.removeItem("accessToken");

      ReactDOM.render(<App pageId="landing-page" />, document.getElementById("app"));
    }
  }

  /*  switches the page, with the root application page acting as a container for the various other
      sub-pages.

      page switching is accomplished by setting the pageId state value. see the render method below
      for more information.

      generally, this method is passed to child components, which will invoke onSwitchPage when they
      want to hand focus over to another page.
  */
  onSwitchPage = (pageId) => {
    this.setState({
      pageId: pageId,
    });
  }

  /*  updates the information about the current application user.

      these values will all be null or undefined if no user is logged in. they are consumed by the
      user status page.

      child components will invoke onUpdateUser when they wish to update the user state after an
      action that changes it, ie: adding to the integer value.
   */ 
  onUpdateUser = (username, name, integerValue) => {
    this.setState({
      username: username,
      name: name, 
      integerValue: integerValue
    });
  }

  render() {
    switch (this.state.pageId) {
      case "landing-page":
        return (
          <main className="root-container">
            <LandingPage onSwitchView={this.onSwitchPage} onUpdateUser={this.onUpdateUser} />
          </main>
        )

      case "register-page":
        return (
          <main className="root-container">
            <RegisterPage onSwitchView={this.onSwitchPage} onUpdateUser={this.onUpdateUser} />
          </main>
        )
      
      case "login-page":
        return (
          <main className="root-container">
            <LoginPage onSwitchView={this.onSwitchPage} onUpdateUser={this.onUpdateUser} />
          </main>
        )

      case "status-page":
        return (
          <main className="root-container">
            <StatusPage username={this.state.username} name={this.state.name} integerValue={this.state.integerValue}
              onSwitchView={this.onSwitchPage} onUpdateUser={this.onUpdateUser} />
          </main>
        )
    }
  }
}

App.Load();
