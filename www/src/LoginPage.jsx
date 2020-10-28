class LoginPage extends React.Component {
  constructor(props) {
    super();

    this.formElement = React.createRef();

    this.onSwitchView = props.onSwitchView;
    this.onUpdateUser = props.onUpdateUser;

    this.state = {
      error: null,
      busy: false
    };
  }

  /*  fires when the back button is clicked; takes the user back to the landing page.
  */
  onBackButtonClick = () => {
    this.onSwitchView("landing-page");
  }

  /*  fires when the login button is clicked; attempts to login with an existing user.

      see the register page documentation for more information on how access tokens are obtained
      and used.
   */
  onLoginButtonClick = async () => {
    if (!this.formElement.current.checkValidity()) {
      this.formElement.current.reportValidity();
      return;
    }

    const formData = new FormData(this.formElement.current);
    const jsonData = JsonApiRequest.fromFormData("users", null, formData);

    this.setState({"busy": true});

    try {
      const response = await fetch(`${Config.API_HOST}/login`, {
        method: "POST",
        cache: "no-cache",
        credentials: "same-origin",
        headers: {
          "Content-Type": "application/vnd.api+json",
          "Accept": "application/vnd.api+json"
        },
        body: JSON.stringify(jsonData)
      });

      const body = await response.json();

      if (response.ok) {
        this.setState({
          "busy": false,
          "error": null
        });
      
        const data = body.data;
        const accessToken = response.headers.get("X-Api-Access-Token");

        localStorage.setItem("userId", data.id);
        localStorage.setItem("accessToken", accessToken);

        this.onUpdateUser(data.attributes.username, data.attributes.name, data.attributes.integer_value);
        this.onSwitchView("status-page");
      } else {
        
        this.setState({
          "busy": false,
          "error": body.errors[0]
        });
      }
    } catch (err) {
      this.setState({
        "busy": false,
        "error": `A form error occurred: ${err}`
      });

      throw err
    }
  }

  render() {
    return (
      <div className="page-container">
        <div className="page">
          <h1>Login</h1>

          <p>Enter your username and password.</p>

          <form ref={this.formElement}>
            <div className="labelled-form-item">
              <input className="form" type="email" name="username" required minLength="1" maxLength="128" disabled={this.state.busy}/>
              <label>Username</label>
            </div>

            <div className="labelled-form-item">
              <input className="form" type="password" name="password" required disabled={this.state.busy} onChange={this.onPasswordFieldChange} />
              <label>Password</label>
            </div>
          </form>

          <div className={this.state.error ? "form-error": "hidden"}>{this.state.error}</div>

          <div className="button-bar">
            <button disabled={this.state.busy} onClick={this.onBackButtonClick}>Back</button>
            <button className="action" disabled={this.state.busy} onClick={this.onLoginButtonClick}>Login</button>
          </div>
        </div>
      </div>
    )
  }
}
