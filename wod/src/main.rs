extern crate reqwest;
extern crate scraper;
extern crate select;

use select::document::Document;
use select::predicate::{Class,Name,Predicate};

fn main() {
    if is_cached() {
    } else {
        wod("http://www.merriam-webster.com/word-of-the-day");
    }
}

fn is_cached() -> bool {
    return false;
}
fn wod(url: &str) {
    let yellow      = "\x1b[1;33m";
    let purple      = "\x1b[0;35m";
    let nc          = "\x1b[0m";

    let resp = reqwest::get(url).unwrap();
    assert!(resp.status().is_success());

    let document    = Document::from_read(resp).unwrap();
    let node        = document.find(Class("word-header")).next().unwrap();
    let word        = node.find(Name("h1")).next().unwrap().text();

    let node        = document.find(Class("word-attributes")).next().unwrap();
    let attr        = node.find(Class("main-attr")).next().unwrap().text();
    let syllables   = node.find(Class("word-syllables")).next().unwrap().text();

    println!("Word of the Day: {}{} : {} ({}){}", yellow, word, attr, syllables, nc);
    for definition in document.find(Class("wod-definition-container").child(Name("p"))) {
        let children: Vec<String> = definition.children().map(|n| n.text()).collect();
        let texts = children.join("");
        println!("     definition: {}{}{}", purple, texts, nc);
    }
}

