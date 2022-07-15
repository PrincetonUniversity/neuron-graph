const $ = require('jquery');

class Welcome {
  constructor(view, controller) {
    this.view = view;
    this.controller = controller;

    this._isRunning;
  }

  isRunning() {
    return this._isRunning;
  }

  start() {
    this._isRunning = true;
    this.view.graph.disableAnimations();

    this.run();
  }

  end() {
    this.stop();
  }

  stop() {
    this._isRunning = false;
    this.view.help.hideWelcome();
    this.view.popup.toggleHighlight('split', false);

    if (!this.view.graph.isSmallScreen()) {
      this.view.graph.enableAnimations();
    }
    this.view.graph.removeSelection();
  }

  coordinate() {
    let { x1, y2 } = this.view.searchbar.getBoundingBox();

    return { x: x1 + 16 + 35, y: y2 };
  }

  position() {
    return 'below-right';
  }

  run() {
      
    (() => {
      let d = $.Deferred();

      d.resolve();
      return d;
    })()
      .then(() => {
        // Update and display welcome.
        this.view.help.setWelcomeContent(
          'FunCoNN (Beta)',
          [
            '<b>Welcome to FuNCoNN (Beta): Functional Connectivity on NemaNode</b>',
            '<p>',
            'This is an interactive browser of functional connectivity measurements of',
            '<i>C. elegans</i> overlaid on select connectomics data using the software package',
            '<b>NemaNode</b>.',
            '<p>',
            'Functional connectivity measurements show the casual direction of information',
            'flow, polarity and functional strength of neural connections based on',
            'optogenetic perturbations and calcium imaging.',
            '<p>',
            'Functional measurements shown in this visualization are from a forthcoming',
            '(in prep) manuscript from the Leifer Lab:',
            '<p>',
            'Randi, Dvali, Sharma & Leifer, <i>Direct Measurements of Functional Connectivity.</i>',
            '<p>',
            'Only those measured connections with a q-value less than 0.05 are shown.',
            '<p>',
            'Measurements are displayed using <b>NemaNode</b> (<i>nemanode.org</i>), an open',
            'source software package described in <i>Witvleit et al., 2021</i> from the',
            'Zhen, Samuel and Licthman labs. Select connectomics datasets from',
            '<i>Witvleit et al</i>, and others, are also displayed.',
            '<p>',
            'This project is in beta and has not yet been peer reviewed.',
            '<p>',
            'Data and code are released under a permissive license at',
            '<i>https://github.com/PrincetonUniversity/neuron-graph</i>'
          ]
        );
        this.view.help.showWelcome(this.coordinate(), this.position());
      });
  }
}

module.exports = Welcome;
