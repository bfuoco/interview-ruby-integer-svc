class RegisterPage extends React.Component {
  constructor(props) {
    super();

    this.formElement = React.createRef();
    this.passwordConfirmFieldElement = React.createRef();

    this.onSwitchView = props.onSwitchView;
    this.onUpdateUser = props.onUpdateUser;

    this.state = {
      error: null,
      busy: false
    };
  }

  /*  fires when the password field changes; updates the pattern attribute of the password
      confirmation field. this is used to provide automatic validation of this input field.
  */
  onPasswordFieldChange = (e) => {
    this.passwordConfirmFieldElement.current.setAttribute("pattern", e.target.value);
  }

  /*  fires when the back button is clicked; takes the user back to the landing page.
  */
  onBackButtonClick = () => {
    this.onSwitchView("landing-page");
  }

  /*  fires when the register button is clicked; attempts to register a new user and if successful,
      opens the user status page.

      the access token is returned from the register request in the response headers. the header is
      not one of the default "cors-safe" headers, so note that the server is explicitly exposing it
      by specifying the Access-Control-Expose-Headers response header.

      this is mostly informational; if you try to re-use this snippet with a different header,
      remember to add the new header to the Access-Control-Expose-Headers response header.

      the access token is cached in local storage for subsequent requests.
   */
  onRegisterButtonClick = async () => {
    if (!this.formElement.current.checkValidity()) {
      this.formElement.current.reportValidity();
      return;
    }

    const formData = new FormData(this.formElement.current);
    const jsonData = JsonApiRequest.fromFormData("users", null, formData);

    this.setState({"busy": true});

    try {
      const response = await fetch(`${Config.API_HOST}/register`, {
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
    }
  }

  render() {
    return (
      <div className="page-container">
        <div className="page">
          <h1>Register</h1>

          <p>Fill in the form below to register.</p>

          <form ref={this.formElement}>
            <div className="labelled-form-item">
              <input className="form" type="email" name="username" required minLength="1" maxLength="128" disabled={this.state.busy}/>
              <label>Username</label>
            </div>

            <div className="labelled-form-item">
              <input className="form" type="password" name="password" required disabled={this.state.busy} onChange={this.onPasswordFieldChange} />
              <label>Password</label>
            </div>

            <div className="labelled-form-item">
              <input ref={this.passwordConfirmFieldElement} className="form" type="password" required disabled={this.state.busy} />
              <label>Confirm password</label>
            </div>

            <div className="labelled-form-item">
              <input className="form" type="text" name="name" required minLength="1" maxLength="100" disabled={this.state.busy} />
              <label>Full name</label>
            </div>
          </form>

          <div className={this.state.error ? "form-error": "hidden"}>{this.state.error}</div>

          <div className="button-bar">
            <button disabled={this.state.busy} onClick={this.onBackButtonClick}>Back</button>
            <button className="action" disabled={this.state.busy} onClick={this.onRegisterButtonClick}>Register</button>
          </div>
        </div>
      </div>
    )
  }
}