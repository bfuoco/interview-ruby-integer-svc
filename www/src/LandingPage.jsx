class LandingPage extends React.Component {
  constructor(props) {
    super();

    this.onSwitchView = props.onSwitchView
  }

  onLoginButtonClick = () => {
    this.onSwitchView("login-page");
  }

  onRegisterButtonClick = () => {
    this.onSwitchView("register-page");
  }

  render() {
    return (
      <div className="page-container">
        <div className="page">
          <h1>Increment Integer</h1>

          <p>The increment integer service will keep track of an integer value for you. If you
            already have an account, click the login button below. If you need to create an
            account; instead, click the register button.</p>

          <div className="button-bar">
            <button id="login-btn" onClick={this.onLoginButtonClick}>Login</button>
            <button id="register-btn" onClick={this.onRegisterButtonClick}>Register</button>
          </div>
        </div>
      </div>
    )
  }
}