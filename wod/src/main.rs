extern crate reqwest;
extern crate scraper;
extern crate select;

use select::document::Document;
use select::predicate::{Class,Name,Predicate};

#[tokio::main]
async fn main() {
    if is_cached() {
    } else {
        wod("http://www.merriam-webster.com/word-of-the-day").await;
    }
}

fn is_cached() -> bool {
    return false;
}
/*
fn print_type_of<T>(_: &T) {
    println!("{}", std::any::type_name::<T>())
}
*/
async fn wod(url: &str) {
    let yellow      = "\x1b[1;33m";
    let purple      = "\x1b[0;35m";
    let nc          = "\x1b[0m";

    let resp = reqwest::get(url).await.unwrap();
    assert!(resp.status().is_success());
    let text = resp.text().await.unwrap();

    let document    = Document::from(text.as_str());
    let node        = document.find(Class("word-header")).next().unwrap();
    let word        = node.find(Name("h2")).next().unwrap().text();
    // println!("word: {:?}",word);

    let node        = document.find(Class("word-attributes")).next().unwrap();
    let attr        = node.find(Class("main-attr")).next().unwrap().text();
    let syllables   = node.find(Class("word-syllables")).next().unwrap().text();
    // println!("attr: {:?}",attr);
    // println!("syllables: {:?}",syllables);

    println!("Word of the Day: {}{} : {} ({}){}", yellow, word, attr, syllables, nc);
    let definitions = document.find(Class("wod-definition-container").child(Name("p")));
    //print_type_of(&definitions);
    for definition in definitions.filter(|d| d.children().nth(0).unwrap().text() != "See the entry >") {
        let children: Vec<String> = definition.children().map(|n| n.text()).collect();
        let texts = children.join("");
        println!("     definition: {}{}{}", purple, texts, nc);
    }
    /*
    match resp.status() {
        reqwest::StatusCode::OK => {
            println!("Success! {:?}");
        },
        reqwest::StatusCode::UNAUTHORIZED => {
            println!("Need to grab a new token");
        },
        _ => {
            panic!("Un oh! Something unexpected happened.");
        },
    };
    */
}

