const $ = require('jquery');

class Welcome {
  constructor(view, controller) {
    this.view = view;
    this.controller = controller;

    this._isRunning;
    this._wasDismissed = false;
  }

  isRunning() {
    return this._isRunning;
  }

  wasDismissed() {
    return this._wasDismissed;
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
    this._wasDismissed = true;
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
            'Welcome to <b>FunCoNN (Beta): <u>Fun</u>ctional <u>Co</u>nnectivity on <u>N</u>ema <u>N</u>ode</b>',
            '<p>',
            'A browser of functional connectivity measurements of <i>C. elegans</i> overlaid ' +
            'on select connectomics data using <a href="https://nemanode.org/" target="_blank">Nema Node</a>.',
            '<p>',
            'Functional connectivity measurements show the causal direction of information flow, polarity ' +
            'and functional strength of neural connections based on optogenetic perturbations and calcium ' +
            'imaging. Functional measurements from a forthcoming manuscript from the ' +
            '<a href="http://leiferlab.princeton.edu/" target="_blank">Leifer Lab</a>: Randi, Sharma, Dvali ' +
            'and Leifer, &#8220A functional connectivity atlas of C. elegans measured by neural activation.&#8221 ' +
            '<a href="https://doi.org/10.48550/arXiv.2208.04790" target="_blank">arXiv</a>, (2022) ' +
            '[<a href="https://arxiv.org/pdf/2208.04790" target="_blank">PDF</a>]',
            '<p>',
            '<b><u>IMPORTANT: Only those measured functional connections  are shown for which we have strong ' +
            'statistical confidence (many observations, large transients, q<0.05). See manuscript for evidence ' +
            'of additional functional connections.</u></b> The absence of significance does not ' +
            'imply significance of absence.',
            '<p>',
            'Measurements are displayed using <a href="https://nemanode.org/" target="_blank">Nema Node</a>, ' +
            'an open source <a href="https://github.com/zhenlab-ltri/NemaNode" target="_blank">software package</a> ' +
            'described in <a href="https://doi.org/10.1038/s41586-021-03778-8" target="_blank">Witvleit et al., 2021</a> ' + 
            'from the <a href="https://www.zhenlab.com/" target="_blank">Zhen</a>, ' +
            '<a href="https://scholar.harvard.edu/aravisamuel" target="_blank">Samuel</a>, and ' +
            '<a href="https://lichtmanlab.fas.harvard.edu" target="_blank">Lichtman</a> labs. Select connectomics ' +
            'datasets from Witvleit et al, and others are also displayed.',
            '<p>',
            'This project is in beta and has not yet been peer reviewed. Data and code are released under ' +
            'a permissive license at <a href="https://github.com/PrincetonUniversity/neuron-graph" ' +
            'target="_blank">https://github.com/PrincetonUniversity/neuron-graph/</a>',
            '<p>',
            'This fork is developed by Research Computing staff in the ' +
            '<a href="https://lsi.princeton.edu" target="_blank">Lewis-Sigler Institute for Integrative ' +
            'Genomics</a> (Robert Leach and Lance Parsons) and the ' +
            '<a href="https://pni.princeton.edu" target="_blank">Princeton Neuroscience Institute</a> ' +
            '(Benjamin Singer). Request features or report bugs on ' +
            '<a href="https://github.com/PrincetonUniversity/neuron-graph/issues" target="_blank">Github</a>.'
          ]
        );
        this.view.help.showWelcome(this.coordinate(), this.position());
      });
  }
}

module.exports = Welcome;
